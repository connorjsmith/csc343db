-- TODO: test the shit out of this, gonna need a large dataset
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
DROP VIEW IF EXISTS GraderAssignmentGroupMarkDate CASCADE;
DROP VIEW IF EXISTS AssignmentTenAveragesForGraders CASCADE;
DROP VIEW IF EXISTS NotGraderForAllAssignments CASCADE;
DROP VIEW IF EXISTS NotSoftGraders CASCADE;
DROP VIEW IF EXISTS GraderAverageAllAssignmentsSpread CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, Assignment.due_date, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

CREATE VIEW GraderAssignmentGroupMarkDate AS (
    SELECT g.username, ad.assignment_id, ag.group_id, (mark * 100/ weighted_divisor) as percentage, ad.due_date
    FROM AssignmentDivisors ad
        JOIN AssignmentGroup ag
            ON ad.assignment_id = ag.assignment_id
        JOIN Result r
            ON ag.group_id = r.group_id
        JOIN Membership m
            ON ag.group_id = m.group_id
        JOIN Grader g
            ON g.group_id = ag.group_id
);

CREATE VIEW AssignmentTenAveragesForGraders AS (
    SELECT username, assignment_id, avg(percentage) as assignment_average, due_date
    FROM GraderAssignmentGroupMarkDate
    GROUP BY username, assignment_id, due_date
    HAVING COUNT(DISTINCT group_id) >= 10
);

CREATE VIEW NotGraderForAllAssignments AS (
    SELECT DISTINCT users.username
    FROM (SELECT username FROM MarkusUser) users CROSS JOIN (SELECT assignment_id FROM Assignment) assignments -- product of all markus usernames and all assignment_ids
    WHERE (users.username, assignments.assignment_id) NOT IN -- select users which have a missing pair in the 10 mark and therefore haven't marked all assignments
        (SELECT username, assignment_id FROM AssignmentTenAveragesForGraders)
);

CREATE VIEW NotSoftGraders AS (
    SELECT l.username
    FROM GraderAssignmentGroupMarkDate l CROSS JOIN GraderAssignmentGroupMarkDate r
    WHERE l.username = r.username -- same grader
        AND l.assignment_id <> r.assignment_id -- different assignments
        AND l.due_date < r.due_date -- The left assignment came first
        AND l.percentage >= r.percentage -- The right assignment wasn't strictly less than the left assignment
);

CREATE VIEW SoftAssignmentTenAveragesForGraders AS (
    SELECT *
    FROM AssignmentTenAveragesForGraders atafg
    WHERE atafg.username NOT IN (SELECT username FROM NotSoftGraders)
);

-- This assumes each assignment has a unique due_date
CREATE VIEW GraderFirstAssignment AS (
    SELECT *
    FROM AssignmentTenAveragesForGraders
    WHERE due_date = (SELECT MIN(due_date) FROM Assignment)
);

-- This assumes each assignment has a unique due_date
CREATE VIEW GraderLastAssignment AS (
    SELECT *
    FROM AssignmentTenAveragesForGraders
    WHERE due_date = (SELECT MAX(due_date) FROM Assignment)
);

CREATE VIEW GraderAverageAllAssignmentsSpread AS (
    SELECT satafg.username,
           avg(satafg.assignment_average) AS average_mark_all_assignments,
           (last_assignment.assignment_average - first_assignment.assignment_average) AS mark_change_first_last
    FROM SoftAssignmentTenAveragesForGraders satafg
        JOIN GraderFirstAssignment first_assignment ON satafg.username = first_assignment.username
        JOIN GraderLastAssignment last_assignment ON satafg.username = last_assignment.username
    GROUP BY satafg.username, first_assignment.assignment_average, last_assignment.assignment_average
);

CREATE VIEW NamedAverageAllAssignmentsSpread AS (
    SELECT firstname || ' ' || surname AS ta_name, average_mark_all_assignments, mark_change_first_last
    FROM GraderAverageAllAssignmentsSpread l JOIN MarkusUser r ON l.username = r.username
);
    
SELECT * FROM GraderAssignmentGroupMarkDate;
SELECT * FROM AssignmentTenAveragesForGraders;
SELECT * FROM NotGraderForAllAssignments;
SELECT * FROM NotSoftGraders;
SELECT * FROM GraderFirstAssignment;
SELECT * FROM GraderLastAssignment;
SELECT * FROM GraderAverageAllAssignmentsSpread;
SELECT * FROM NamedAverageAllAssignmentsSpread;

-- Final answer.
INSERT INTO q2 (SELECT * FROM NamedAverageAllAssignmentsSpread);
SELECT * FROM q2; -- TODO: remove
