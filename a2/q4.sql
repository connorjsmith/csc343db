-- Grader report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q4;

-- You must not change this table definition.
CREATE TABLE q4 (
	assignment_id integer,
	username varchar(25), 
	num_marked integer, 
	num_not_marked integer,
	min_mark real,
	max_mark real
);

DROP VIEW IF EXISTS AssignmentDivisors CASCADE;
DROP VIEW IF EXISTS AssignmentGraderGroupMark CASCADE;
DROP VIEW IF EXISTS AssignmentGraderCountMinMaxMark CASCADE;

-- Define views for your intermediate steps here
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, Assignment.due_date, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

-- Associate every grader with their (possibly null) groups and (possibly null) grades for each group
CREATE VIEW AssignmentGraderGroupMark AS (
    SELECT ad.assignment_id, g.username, ag.group_id, (mark * 100/ weighted_divisor) AS mark
    FROM AssignmentDivisors ad -- For weighted_divisor for assignment_id
        JOIN AssignmentGroup ag -- To map between group_id and assignment_id
            ON ad.assignment_id = ag.assignment_id
        JOIN Grader g -- For grader/group associations, grader username
            ON g.group_id = ag.group_id
        LEFT JOIN Result r -- For mark (possibly no mark recorded for that group yet)
            ON ag.group_id = r.group_id
);

-- Group By assignment_id, username. Aggregate COUNT(marks) AS num_marked, (COUNT(*) - COUNT(marks)) AS num_not_marked, MIN(mark) as min_mark, MAX(mark) as max_mark
-- TODO: need a test case where there isn't a grade recorded for a group to see that the count(*) - count(mark) logic works as expected
-- TODO: need a test case where there isn't a grader recorded for a group, to make sure it doesn't appear
CREATE VIEW AssignmentGraderCountMinMaxMark AS (
	SELECT assignment_id, -- should be included if there is at least one grader declared for the assignment
	       username, -- grader username, shouldn't be null (TODO?)
		   COUNT(mark) AS num_marked,  -- will only count actual marks recorded
	       COUNT(*) - COUNT(mark) AS num_not_marked, -- number including nulls - number exluding nulls = number of nulls. If all null columns count(mark) = 0
	       MIN(mark) AS min_mark, -- possibly null
	       MAX(mark) AS max_mark  -- possibly null
	FROM AssignmentGraderGroupMark
	GROUP BY assignment_id, username
);

-- Final answer.
INSERT INTO q4 (SELECT * FROM AssignmentGraderCountMinMaxMark);
