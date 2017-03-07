-- Grader report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q4;

-- You must not change this table definition.
CREATE TABLE q4 (
	assignment_id integer,
	username varchar(25), 
	num_marked integer, 
	num_not_marked integer,
	min_mark real,
	max_mark real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Final answer.
INSERT INTO q4
	-- put a final query here so that its results will go into the table.





-- Associate every grader with their (possibly null) groups and (possibly null) grades for each group
-- Group By assignment_id, username. Aggregate COUNT(marks) AS num_marked, (COUNT(*) - COUNT(marks)) AS num_not_marked, MIN(mark) as min_mark, MAX(mark) as max_mark
