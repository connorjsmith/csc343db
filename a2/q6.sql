-- Steady work

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q6;

-- You must not change this table definition.
CREATE TABLE q6 (
    group_id integer,
    first_file varchar(25),
    first_time timestamp,
    first_submitter varchar(25),
    last_file varchar(25),
    last_time timestamp, 
    last_submitter varchar(25),
    elapsed_time interval
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Final answer.
INSERT INTO q6
    -- put a final query here so that its results will go into the table.




-- Filter to find assignment_id with description = 'A1'
-- JOIN to get assignment_id | group_id | submission_date for every submission by a group on that assignment
-- CREATE VIEW first_submissions_per_group AS (assignment_id, group_id, MIN(submission_date))
-- CREATE VIEW last_submissions_per_group AS (assignment_id, group_id, MAX(submission_date))
-- Cross product these two tables, joined on assignment_id and group_id



-- Get other info about these submissions along the way, as per the schema 
