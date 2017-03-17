-- Piazza clarification @365 "for all students there exists an assignment that the grader has marked."
-- High coverage

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q7;

-- You must not change this table definition.
CREATE TABLE q7 (
    ta varchar(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS AllGraderUsernames CASCADE;
DROP VIEW IF EXISTS AllStudentUsernames CASCADE;
DROP VIEW IF EXISTS AllAssignments CASCADE;
DROP VIEW IF EXISTS GraderAssignments CASCADE;
DROP VIEW IF EXISTS GraderStudents CASCADE;
DROP VIEW IF EXISTS AllGraderUsernamesAllAssignments CASCADE;
DROP VIEW IF EXISTS AllGraderUsernamesAllStudentUsernames CASCADE;

CREATE VIEW AllGraderUsernames AS (
    SELECT username
    FROM MarkusUser
    WHERE type = 'instructor' or type = 'TA'
);

CREATE VIEW AllStudentUsernames AS (
    SELECT username
    FROM MarkusUser
    WHERE type = 'student'
);

CREATE VIEW AllAssignments AS (
    SELECT assignment_id
    FROM Assignment
);

-- product AllGraderUsernames with all assignments
CREATE VIEW AllGraderUsernamesAllAssignments AS (
    SELECT username, assignment_id
    FROM AllGraderUsernames CROSS JOIN AllAssignments as a
);

-- product AllGraderUsernames with all student markus users
CREATE VIEW AllGraderUsernamesAllStudentUsernames AS (
    SELECT agu.username AS grader_username, asu.username AS student_username
    FROM AllGraderUsernames agu CROSS JOIN AllStudentUsernames asu
);

-- Join graders with assignments they have been assigned to grade
CREATE VIEW GraderAssignments AS (
    SELECT DISTINCT username, assignment_id -- Distinct because we only need one entry per grader-assignment pair
    FROM Grader        -- grader username, group_id
        JOIN AssignmentGroup -- group_id, assignment_id
            ON Grader.group_id = AssignmentGroup.group_id
);

-- join graders with students they have been assigned to grade
CREATE VIEW GraderStudents AS (
    SELECT DISTINCT Grader.username AS grader_username, Membership.username as student_username -- Distinct because we only need one entry per grader-student pair
    FROM Grader -- grader username, group_id
        JOIN Membership -- group_id, student username
            ON Grader.group_id = Membership.group_id
);

-- LowCoverageGraders = AssignmentProduct - AssignmentJoins - (StudentProduct - StudentJoins), distinct on username
CREATE VIEW NotAllAssignmentGraders AS (
    SELECT DISTINCT username
    FROM (SELECT * FROM AllGraderUsernamesAllAssignments
              EXCEPT
          SELECT * FROM GraderAssignments) t
);
CREATE VIEW NotAllStudentGraders AS (
    SELECT DISTINCT grader_username AS username
    FROM (SELECT grader_username, student_username FROM AllGraderUsernamesAllStudentUsernames
              EXCEPT
          SELECT grader_username, student_username FROM GraderStudents) t
);

CREATE VIEW LowCoverageGraders AS (
    SELECT username FROM NotAllAssignmentGraders
        UNION
    SELECT username FROM NotAllStudentGraders
);
-- HighCoverageGraders = AllGraderUsernames - LowCoverageGraders, DISTINCT'd by using EXCEPT instead of EXCEPT ALL
CREATE VIEW HighCoverageGraders AS (
    SELECT username FROM AllGraderUsernames
        EXCEPT
    SELECT username FROM LowCoverageGraders
);

-- Final answer.
INSERT INTO q7 (SELECT username AS ta FROM HighCoverageGraders); -- rename to 'ta' to match the schema
