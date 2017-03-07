-- Solo superior
-- NOTE: piazza #379 drops the requirement that the final result must be "solo superior".
--          Instead, report for all groups the required information

-- TODO: add some solo teams for assignment 1000

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q3;

DROP VIEW IF EXISTS AssignmentDivisors CASCADE;
DROP VIEW IF EXISTS StudentAssignmentGroupMark CASCADE;
DROP VIEW IF EXISTS AssignmentGroupMarkSize CASCADE;
DROP VIEW IF EXISTS SoloAssignmentGroupMark CASCADE;
DROP VIEW IF EXISTS SoloAssignmentAverages CASCADE;
DROP VIEW IF EXISTS TeamedAssignmentGroupMark CASCADE;
DROP VIEW IF EXISTS TeamedAssignmentAverages CASCADE;
DROP VIEW IF EXISTS SoloTeamedAveragesCounts CASCADE;

-- You must not change this table definition.
CREATE TABLE q3 (
    assignment_id integer,
    description varchar(100), 
    num_solo integer, 
    average_solo real,
    num_collaborators integer, 
    average_collaborators real, 
    average_students_per_group real
);

-- Define views for your intermediate steps here
CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, Assignment.due_date, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

CREATE VIEW StudentAssignmentGroupMark AS (
    SELECT m.username, ad.assignment_id, (mark * 100/ weighted_divisor) AS mark, ag.group_id
    FROM AssignmentDivisors ad -- For weighted_divisor for assignment_id
        JOIN AssignmentGroup ag -- To map between group_id and assignment_id
            ON ad.assignment_id = ag.assignment_id
        JOIN Result r -- For mark
            ON ag.group_id = r.group_id
        JOIN Membership m -- For student username belonging to group_id
            ON ag.group_id = m.group_id
);

-- CREATE VIEW StudentAssignmentGroupMark AS ( TODO ); -- contains student_user | assignment_id | group_id | mark
CREATE VIEW AssignmentGroupMarkSize AS (
    SELECT assignment_id, group_id, mark, COUNT(group_id) as group_size
    FROM StudentAssignmentGroupMark
    GROUP BY assignment_id, group_id, mark
);

-- This pads an assigment with nulls if there are no solo groups
CREATE VIEW SoloAssignmentGroupMark AS (
    SELECT a.assignment_id, solo.group_id, solo.mark
    FROM Assignment a LEFT JOIN (
        SELECT assignment_id, group_id, mark
        FROM AssignmentGroupMarkSize
        WHERE group_size = 1
    ) solo ON a.assignment_id = solo.assignment_id
);
-- avg(null) should return null
CREATE VIEW SoloAssignmentAverages AS (
    SELECT assignment_id, avg(mark) as average_mark_for_solo
    FROM SoloAssignmentGroupMark
    GROUP BY assignment_id
);

-- This pads an assigment with nulls if there are no non-solo groups
CREATE VIEW TeamedAssignmentGroupMark AS (
    SELECT a.assignment_id, team.group_id, team.group_size, team.mark
    FROM Assignment a LEFT JOIN (
        SELECT assignment_id, group_id, mark, group_size
        FROM AssignmentGroupMarkSize
        WHERE group_size > 1
    ) team ON a.assignment_id = team.assignment_id
);
-- avg(null) should return null
CREATE VIEW TeamedAssignmentAverages AS (
    SELECT assignment_id, avg(mark) as average_mark_for_teams
    FROM TeamedAssignmentGroupMark
    GROUP BY assignment_id
);

CREATE VIEW SoloTeamedAveragesCounts AS (
    SELECT solo.assignment_id,                              -- All assignments will be present, even with no teams/grades
           COUNT(DISTINCT solo.group_id) as num_solo,       -- Will return 0 for no solo teams as expected.
           average_mark_for_solo as average_solo,           -- Will return null for no solo teams
           SUM(tagm.group_size) as num_collaborators,       -- TODO: will return null. maybe use a case statement here?
           average_mark_for_teams as average_collaborators, -- Will return null as expected for zero collaborative teams
           average_students_per_group                       -- TODO: will return null if no teams (solo and collaborative). probably want 0 here with a case statement
    FROM SoloAssignmentGroupMark solo
         LEFT JOIN SoloAssignmentAverages saa ON solo.assignment_id = saa.assignment_id
         LEFT JOIN TeamedAssignmentGroupMark tagm ON solo.assignment_id = tagm.assignment_id
         LEFT JOIN TeamedAssignmentAverages taa ON solo.assignment_id = taa.assignment_id
         LEFT JOIN (SELECT assignment_id, AVG(group_size) AS average_students_per_group FROM AssignmentGroupMarkSize GROUP BY assignment_id) all_students
             ON solo.assignment_id = all_students.assignment_id
    GROUP BY solo.assignment_id, average_mark_for_solo, average_mark_for_teams, average_students_per_group
);

SELECT * FROM SoloAssignmentGroupMark;
SELECT * FROM TeamedAssignmentGroupMark;
SELECT * FROM SoloTeamedAveragesCounts;
-- Final answer.
-- INSERT INTO q3
    -- put a final query here so that its results will go into the table.
