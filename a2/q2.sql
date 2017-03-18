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
DROP VIEW IF EXISTS NamedAverageAllAssignmentsSpread CASCADE;

-- Define views for your intermediate steps here.
-- assignment_id, due_date, weighted_divisor?
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, Assignment.due_date, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS PartialDivisors on Assignment.assignment_id = PartialDivisors.assignment_id
    GROUP BY Assignment.assignment_id
);

-- Joins a grader to their assignments and marks for those assignments. Exclude any percentages which could be null
-- username, assignment_id, group_id, percentage?, due_date
CREATE VIEW GraderAssignmentGroupMarkDate AS (
    SELECT g.username, ad.assignment_id, ag.group_id, (mark * 100/ weighted_divisor) as percentage, ad.due_date
    FROM AssignmentDivisors ad -- assignment_id, weighted_divisor?
        JOIN AssignmentGroup ag -- group_id, assignment_id?, repo
            ON ad.assignment_id = ag.assignment_id
        JOIN Result r -- group_id, mark, released?
            ON ag.group_id = r.group_id
        JOIN Membership m -- username, group_id -> add a row for every member in that group
            ON ag.group_id = m.group_id
        JOIN Grader g -- group_id, username?
            ON g.group_id = ag.group_id
    WHERE g.username IS NOT NULL
          AND weighted_divisor IS NOT NULL -- only include rows where percentage IS NOT NULL
);

-- username, assignment_id, assignment_average, due_date
CREATE VIEW AssignmentTenAveragesForGraders AS (
    SELECT username, assignment_id, avg(percentage) as assignment_average, due_date
    FROM GraderAssignmentGroupMarkDate
    GROUP BY username, assignment_id, due_date
    HAVING COUNT(DISTINCT group_id) >= 10 -- only include assignment averages when the grader has marked >= 10 groups
);

-- username
CREATE VIEW NotGraderForAllAssignments AS (
    SELECT DISTINCT users.username
    FROM (SELECT username FROM MarkusUser) users CROSS JOIN (SELECT assignment_id FROM Assignment) assignments -- product of all markus usernames and all assignment_ids
    WHERE (users.username, assignments.assignment_id) NOT IN -- select users which have a missing pair in the 10 mark and therefore haven't marked all assignments
        (SELECT username, assignment_id FROM AssignmentTenAveragesForGraders)
);

-- username
CREATE VIEW NotSoftGraders AS (
    SELECT l.username
    FROM GraderAssignmentGroupMarkDate l CROSS JOIN GraderAssignmentGroupMarkDate r
    WHERE l.username = r.username -- same grader
        AND l.assignment_id <> r.assignment_id -- different assignments
        AND l.due_date < r.due_date -- The left assignment came first
        AND l.percentage >= r.percentage -- The right assignment wasn't strictly less than the left assignment
);

-- username, assignment_id, assignment_average, due_date
CREATE VIEW SoftAssignmentTenAveragesForGraders AS (
    SELECT *
    FROM AssignmentTenAveragesForGraders atafg
    WHERE atafg.username NOT IN (SELECT username FROM NotSoftGraders) -- remove soft graders
);

-- This assumes each assignment has a unique due_date (given in A2.pdf)
-- username, assignment_id, assignment_average, due_date
CREATE VIEW GraderFirstAssignment AS (
    SELECT *
    FROM AssignmentTenAveragesForGraders
    WHERE due_date = (SELECT MIN(due_date) FROM Assignment)
);

-- This assumes each assignment has a unique due_date (given in A2.pdf)
-- username, assignment_id, assignment_average, due_date
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
        -- username, assignment_id, assignment_average, due_date
        JOIN GraderFirstAssignment first_assignment ON satafg.username = first_assignment.username
        -- username, assignment_id, assignment_average, due_date
        JOIN GraderLastAssignment last_assignment ON satafg.username = last_assignment.username
    GROUP BY satafg.username, first_assignment.assignment_average, last_assignment.assignment_average
);

CREATE VIEW NamedAverageAllAssignmentsSpread AS (
    SELECT firstname || ' ' || surname AS ta_name, average_mark_all_assignments, mark_change_first_last
    FROM GraderAverageAllAssignmentsSpread l JOIN MarkusUser r ON l.username = r.username
);
    
-- Final answer.
INSERT INTO q2 (SELECT * FROM NamedAverageAllAssignmentsSpread);
