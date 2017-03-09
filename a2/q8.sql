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
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Final answer.
INSERT INTO q8
	-- put a final query here so that its results will go into the table.


-- Map all students to their actual group sizes and the max group sizes for every assignment they participated in, remove students where actual_group_size = 1 and max_group_size > 1
-- Remove students which didn't have a submission on at least one of the assignments (subquery).
	-- TODO: How to handle solo workers without a submission?
-- Map the above students to their grades for these assignments
-- Calculate average for group_size = 1 and group_size > 1, probably in separate views. Join together for final result
