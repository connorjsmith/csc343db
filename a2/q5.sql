-- Uneven workloads

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q5;

-- You must not change this table definition.
CREATE TABLE q5 (
	assignment_id integer,
	username varchar(25), 
	num_assigned integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS AssignmentDivisors CASCADE;
DROP VIEW IF EXISTS GraderAssignmentGroup CASCADE;
DROP VIEW IF EXISTS GraderAssignmentGroupCount CASCADE;
DROP VIEW IF EXISTS AssignmentGroupCountSpread CASCADE;
DROP VIEW IF EXISTS GraderAssignmentGroupCountSpreadOverTen CASCADE;

-- Define views for your intermediate steps here
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, Assignment.due_date, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

-- Associate assignment_id, (nullable) group_id, (nullable) grader_username for every group_id
CREATE VIEW GraderAssignmentGroup AS (
    SELECT g.username, ag.assignment_id, ag.group_id
    FROM AssignmentGroup ag -- To map between group_id and assignment_id
		JOIN Grader g -- For grader/group associations, grader username
			ON g.group_id = ag.group_id
);

-- Group By assignment_id, grader_username for number of groups for that grader/assignment pair
CREATE VIEW GraderAssignmentGroupCount AS (
	SELECT username, assignment_id, COUNT(group_id) AS group_count
	FROM GraderAssignmentGroup
	GROUP BY username, assignment_id
);

-- Calculate the group count spread
CREATE VIEW AssignmentGroupCountSpread AS (
	SELECT assignment_id, MIN(group_count), MAX(group_count), MAX(group_count) - MIN(group_count) AS group_spread
	FROM GraderAssignmentGroupCount
	GROUP BY assignment_id
);

-- Show all graders for assignments with spread > 10
CREATE VIEW GraderAssignmentGroupCountSpreadOverTen AS (
	SELECT gagc.assignment_id, gagc.username, gagc.group_count
	FROM GraderAssignmentGroupCount gagc
		JOIN AssignmentGroupCountSpread spread
			ON gagc.assignment_id = spread.assignment_id
	WHERE spread.group_spread > 10
);


-- Final answer.
INSERT INTO q5 (SELECT * FROM GraderAssignmentGroupCountSpreadOverTen);

