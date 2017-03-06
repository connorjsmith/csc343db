-- Getting soft

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q2;

-- You must not change this table definition.
CREATE TABLE q2 (
        ta_name varchar(100),
        average_mark_all_assignments real,
        mark_change_first_last real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS AssignmentDivisors CASCADE;
DROP VIEW IF EXISTS AssignmentPercentageGrade CASCADE;
DROP VIEW IF EXISTS NotSoftGraders CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, Assignment.due_date, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

-- Pad with nulls for Assignments without groups or without results for any group
CREATE VIEW AssignmentPercentageGrade AS (
    SELECT g.username, ad.assignment_id, ag.group_id, (mark * 100/ weighted_divisor) as percentage, ad.due_date
    FROM AssignmentDivisors ad
        LEFT JOIN AssignmentGroup ag
            ON ad.assignment_id = ag.assignment_id
        LEFT JOIN Result r
            ON ag.group_id = r.group_id
                JOIN Membership m
                        ON ag.group_id = m.group_id
                JOIN Grader g
                        ON g.group_id = ag.group_id
);

CREATE VIEW AssignmentTenAveragesForGraders AS (
    SELECT username, assignment_id, avg(percentage) as assignment_average, due_date
    FROM AssignmentPercentageGrade
    GROUP BY username, assignment_id, due_date
    HAVING COUNT(DISTINCT group_id) >= 10
);

-- TODO: do this
-- CREATE VIEW NotGraderForAllAssignments AS (
-- 
-- );

CREATE VIEW NotSoftGraders AS (
    SELECT l.username
    FROM AssignmentPercentageGrade l CROSS JOIN AssignmentPercentageGrade r
    WHERE l.username = r.username -- same grader
        AND l.assignment_id <> r.assignment_id -- different assignments
        AND l.due_date < r.due_date -- The left assignment came first
        AND l.percentage >= r.percentage -- The right assignment wasn't strictly less than the left assignment
);

SELECT * FROM AssignmentPercentageGrade;
SELECT * FROM AssignmentTenAveragesForGraders;
SELECT * FROM NotSoftGraders;
-- Final answer.
-- INSERT INTO q2 
        -- put a final query here so that its results will go into the table.
