-- Create a table of the weighted items
-- IE. for a rubric with assignment_id=123,group_id=456 sections weighted 2/20% and 4/80%, and grades 1 and 4,
-- output (assignment_id, group_id, section_grade) of {(123, 456, 1/2 * 20), (123, 456, 4/4*80)}
-- A groups mark for an assignment is the group-by (assignment_id, group_id) and sum(section_grade)

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q1;

-- You must not change this table definition.
CREATE TABLE q1 (
	assignment_id integer,
	average_mark_percent real,
	num_80_100 integer,
	num_60_79 integer,
	num_50_59 integer,
	num_0_49 integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

-- Reset all views
DROP VIEW IF EXISTS CountedBucketStudentPercentages;
DROP VIEW IF EXISTS BucketedStudentPercentages;
DROP VIEW IF EXISTS StudentPercentageGrade;
DROP VIEW IF EXISTS GroupAssignmentPercentageGrade;
DROP VIEW IF EXISTS AssignmentDivisors;

-- Define views for intermediate results
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

-- Pad with nulls for Assignments without groups or without results for any group
CREATE VIEW GroupAssignmentPercentageGrade AS (
    SELECT ad.assignment_id, ag.group_id, (mark * 100/ weighted_divisor) as percentage
    FROM AssignmentDivisors ad
        LEFT JOIN AssignmentGroup ag
            ON ad.assignment_id = ag.assignment_id
        LEFT JOIN Result r
            ON ag.group_id = r.group_id
);

-- Pad with nulls for Assignments without members
CREATE VIEW StudentPercentageGrade AS (
    SELECT assignment_id, username, percentage
    FROM GroupAssignmentPercentageGrade g LEFT JOIN Membership m 
        ON g.group_id = m.group_id
);

CREATE VIEW BucketedStudentPercentages AS (
    SELECT assignment_id,
           username,
           percentage,
           (CASE WHEN (percentage >= 80 AND percentage <= 100) THEN 1 ELSE 0 END) as bool80_100,
           (CASE WHEN (percentage >= 60 AND percentage < 80) THEN 1 ELSE 0 END) as bool60_79,
           (CASE WHEN (percentage >= 50 AND percentage < 60) THEN 1 ELSE 0 END) as bool50_59,
           (CASE WHEN (percentage < 50) THEN 1 ELSE 0 END) as bool_50
    FROM StudentPercentageGrade
);

CREATE VIEW CountedBucketStudentPercentages AS (
    SELECT assignment_id, 
           avg(percentage) as average_mark_percentage, 
           sum(bool80_100) as num_80_100,
           sum(bool60_79) as num_60_79,
           sum(bool50_59) as num_50_59,
           sum(bool_50) as num_0_49
    FROM BucketedStudentPercentages
    GROUP BY assignment_id

);    

INSERT INTO q1 (SELECT * FROM CountedBucketStudentPercentages);
SELECT * FROM q1;

