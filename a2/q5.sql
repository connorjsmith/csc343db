-- Uneven workloads

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q5;

-- You must not change this table definition.
CREATE TABLE q5 (
	assignment_id integer,
	username varchar(25), 
	num_assigned integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Final answer.
INSERT INTO q5 
	-- put a final query here so that its results will go into the table.


-- Associate assignment_id, (nullable) group_id, (nullable) grader_username for every group_id
-- Group By assignment_id, grader_username. COUNT(DISTINCT group_id) as num_assigned
-- Filter above by assignment_id, GROUP BY grader_username, assignment_id. HAVING MAX(num_assigned) - MIN(num_assigned) >= 10

-- Null assignments (no graders, no groups, etc.) should no be reported (TODO: i think?)
