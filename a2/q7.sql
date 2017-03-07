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
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Final answer.
INSERT INTO q7 
	-- put a final query here so that its results will go into the table.

-- product AllGraderUsernames with all assignments
-- product AllGraderUsernames with all student markus users
-- Join graders with assignments they have graded (join a couple tables for this)
-- join graders with students they have been assigned to grade
-- LowCoverageGraders = AssignmentProduct - AssignmentJoins - (StudentProduct - StudentJoins), distinct on username
-- HighCoverageGraders = AllGraderUsernames - LowCoverageGraders, be sure to distinct this

