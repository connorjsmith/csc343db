-- Inseparable

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q9;

-- You must not change this table definition.
CREATE TABLE q9 (
	student1 varchar(25),
	student2 varchar(25)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Final answer.
INSERT INTO q9 
	-- put a final query here so that its results will go into the table.


-- Create every (student1, student2) username pair
-- List all assignments that had max_group_size >= 2
-- IF student1 has a group for that assignment, then student2 must be in the same group, otherwise remove this pair
-- (student1, student2) and (student2, student1) must remain after the above steps for it to be included in the final answer.
--      Only include pairs where student1 < student2 alphabetically
