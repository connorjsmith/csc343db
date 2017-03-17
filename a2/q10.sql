-- A1 report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q10;

-- You must not change this table definition.
CREATE TABLE q10 (
    group_id integer,
    mark real,
    compared_to_average real,
    status varchar(5)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS AssignmentDivisors CASCADE;
DROP VIEW IF EXISTS GroupAssignmentAverage CASCADE;
DROP VIEW IF EXISTS A1AssignmentId CASCADE;
DROP VIEW IF EXISTS AssignmentAverage CASCADE;
DROP VIEW IF EXISTS GroupAssignmentAvgComparison CASCADE;


-- Define views for intermediate results
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN ( -- all assignments will appear, even if no rubric items are defined
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

-- Pad with nulls for Assignments without groups or without results for any group
CREATE VIEW GroupAssignmentAverage AS (
    SELECT ad.assignment_id, ag.group_id, (mark * 100/ weighted_divisor) as percentage
    FROM AssignmentDivisors ad
        LEFT JOIN AssignmentGroup ag
            ON ad.assignment_id = ag.assignment_id
        LEFT JOIN Result r
            ON ag.group_id = r.group_id
);

-- Find A1 assignment_id
CREATE VIEW A1AssignmentId AS (
    SELECT assignment_id
    FROM Assignment
    WHERE description = 'A1'
);

-- Calculate the average for each assignment across all groups
CREATE VIEW AssignmentAverage AS (
    SELECT assignment_id, AVG(percentage) as assignment_average
    FROM GroupAssignmentAverage gaa
    WHERE assignment_id IN (SELECT assignment_id FROM A1AssignmentId)
    GROUP BY assignment_id
);

-- Join every group grade with the assignment average, and calculate their performance relative to the assignment avg
CREATE VIEW GroupAssignmentAvgComparison AS (
    SELECT group_id,
           percentage,
           percentage - assignment_average AS compared_to_average,
           (CASE
               WHEN percentage < assignment_average THEN 'below'
               WHEN percentage = assignment_average THEN 'at'
               WHEN percentage > assignment_average THEN 'above'
               ELSE NULL
           END) AS status
    FROM GroupAssignmentAverage gaa
        JOIN AssignmentAverage aa
            ON gaa.assignment_id = aa.assignment_id
);
    

-- Final answer.
INSERT INTO q10 ( SELECT * FROM GroupAssignmentAvgComparison);
