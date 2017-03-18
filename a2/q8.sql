-- Never solo by choice

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q8;

-- You must not change this table definition.
CREATE TABLE q8 (
	username varchar(25),
	group_average real,
	solo_average real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS StudentGroup CASCADE;
DROP VIEW IF EXISTS AssignmentDivisors CASCADE;
DROP VIEW IF EXISTS GroupGrades CASCADE;
DROP VIEW IF EXISTS GroupMembershipCount CASCADE;
DROP VIEW IF EXISTS StudentGroupMaxSize CASCADE;
DROP VIEW IF EXISTS SoloByChoiceStudents CASCADE;
DROP VIEW IF EXISTS NonContributingStudents CASCADE;
DROP VIEW IF EXISTS MatchingStudents CASCADE;
DROP VIEW IF EXISTS MatchingStudentsGrades CASCADE;
DROP VIEW IF EXISTS MatchingStudentsGroupAverages CASCADE;
DROP VIEW IF EXISTS MatchingStudentsSoloAverages CASCADE;
DROP VIEW IF EXISTS MatchingStudentsSoloAndGroupAverages CASCADE;

-- Define views for your intermediate steps here.
-- Map all students to their groups and the max group size
CREATE VIEW StudentGroup AS (
    SELECT username, Membership.group_id, group_max AS max_group_size
    FROM Membership 
        JOIN AssignmentGroup
            ON Membership.group_id = AssignmentGroup.group_id
        JOIN Assignment
            ON AssignmentGroup.assignment_id = Assignment.assignment_id
);

CREATE VIEW AssignmentDivisors AS (
    SELECT Assignment.assignment_id, SUM(partial_divisor) AS weighted_divisor
    FROM Assignment LEFT JOIN (
        SELECT assignment_id, rubric_id, (out_of * weight) as partial_divisor
        FROM RubricItem
    ) AS IntermediateResult on Assignment.assignment_id = IntermediateResult.assignment_id
    GROUP BY Assignment.assignment_id
);

-- Pad with nulls for Assignments without groups or without results for any group
CREATE VIEW GroupGrades AS (
    SELECT ag.group_id, (mark * 100/ weighted_divisor) AS grade
    FROM AssignmentGroup ag -- Groups should always appear
        LEFT JOIN AssignmentDivisors ad
            ON ad.assignment_id = ag.assignment_id
        LEFT JOIN Result r
            ON ag.group_id = r.group_id
);

CREATE VIEW GroupMembershipCount AS (
    SELECT group_id, COUNT(username) as actual_group_size
    FROM Membership
    GROUP BY group_id
);

-- Map all students to their actual group sizes and the max group sizes for every assignment they participated in
CREATE VIEW StudentGroupSizeMaxSize AS (
    SELECT username, StudentGroup.group_id, actual_group_size, max_group_size
    FROM StudentGroup
        JOIN GroupMembershipCount
            ON StudentGroup.group_id = GroupMembershipCount.group_id
);

-- find students where actual_group_size = 1 and max_group_size > 1
CREATE VIEW SoloByChoiceStudents AS (
    SELECT DISTINCT username
    FROM StudentGroupSizeMaxSize
    WHERE actual_group_size = 1 AND max_group_size > 1
);

-- Find students which didn't have a submission for a group
CREATE VIEW NonContributingStudents AS (
    SELECT sg.username
    FROM StudentGroup sg
    WHERE NOT EXISTS (SELECT submission_id  -- Students without a submission for that group_id
                      FROM Submissions 
                      WHERE username = sg.username AND group_id = sg.group_id)
);

-- Find the matching students based on the provided criteria
CREATE VIEW MatchingStudents AS (
    SELECT username FROM StudentGroupSizeMaxSize 
    EXCEPT 
    SELECT username FROM NonContributingStudents 
    EXCEPT 
    SELECT username FROM SoloByChoiceStudents
);

-- Map the above students to their grades for these assignments
CREATE VIEW MatchingStudentsGrades AS (
    SELECT MatchingStudents.username, StudentGroupSizeMaxSize.group_id, actual_group_size, max_group_size, GroupGrades.grade
    FROM StudentGroupSizeMaxSize
        JOIN MatchingStudents -- Remove any students which aren't matching
            ON StudentGroupSizeMaxSize.username = MatchingStudents.username
        LEFT JOIN GroupGrades -- Keep students without grades for these assignments, so we can report null
            ON StudentGroupSizeMaxSize.group_id = GroupGrades.group_id
);

-- Calculate average for group_size = 1 and group_size > 1, probably in separate views. Join together for final result
CREATE VIEW MatchingStudentsSoloAverages AS (
    SELECT username, AVG(grade) AS solo_average -- solo_average might be null, which is fine
    FROM MatchingStudentsGrades
    WHERE max_group_size = 1-- Only matching students which were forced to work alone for this assignment
    GROUP BY username
);

CREATE VIEW MatchingStudentsGroupAverages AS (
    SELECT username, AVG(grade) AS group_average -- group_average might be null, which is fine
    FROM MatchingStudentsGrades
    WHERE max_group_size > 1-- Only matching students which were forced to work alone for this assignment
    GROUP BY username
);

CREATE VIEW MatchingStudentsSoloAndGroupAverages AS (
    SELECT COALESCE(g.username, s.username, NULL) AS username, solo_average, group_average
    FROM MatchingStudentsSoloAverages s
        FULL JOIN MatchingStudentsGroupAverages g -- include students which only have group averages or only have solo averages
            ON s.username = g.username
);

-- Final answer.
INSERT INTO q8 (SELECT username, solo_average, group_average FROM MatchingStudentsSoloAndGroupAverages);
	-- put a final query here so that its results will go into the table.
