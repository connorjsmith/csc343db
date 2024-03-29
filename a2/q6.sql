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
DROP VIEW IF EXISTS A1AssignmentGroupSubmissions CASCADE;
DROP VIEW IF EXISTS FirstSubmissionsPerGroup CASCADE;
DROP VIEW IF EXISTS LastSubmissionsPerGroup CASCADE;
DROP VIEW IF EXISTS FirstLastSubmissionsPerGroup CASCADE;

-- Define views for your intermediate steps here.
-- JOIN to get assignment_id | group_id | submission_date for every submission by a group on that assignment
-- Filter to find assignment_id with description = 'A1'
CREATE VIEW A1AssignmentGroupSubmissions AS (
    SELECT ag.assignment_id, ag.group_id, s.file_name, s.username, s.submission_date
    FROM AssignmentGroup ag
        JOIN Assignment a
            ON ag.assignment_id = a.assignment_id
        LEFT JOIN Submissions s -- might not have a submission
            ON ag.group_id = s.group_id
    WHERE a.description = 'A1'
);

-- CREATE VIEW FirstSubmissionsPerGroup AS (assignment_id, group_id, MIN(submission_date))
CREATE VIEW FirstSubmissionsPerGroup AS (
    SELECT assignment_id,
           group_id,
           file_name AS first_file,
           submission_date AS first_time,
           username AS first_submitter
    FROM A1AssignmentGroupSubmissions outer_table
    WHERE submission_date = (
        SELECT MIN(submission_date)
        FROM A1AssignmentGroupSubmissions
        WHERE outer_table.assignment_id = assignment_id
            AND outer_table.group_id = group_id
    ) OR submission_date IS NULL -- include groups with no submissions
);

-- CREATE VIEW FirstSubmissionsPerGroup AS (assignment_id, group_id, MIN(submission_date))
CREATE VIEW LastSubmissionsPerGroup AS (
    SELECT outer_table.assignment_id,
           group_id,
           file_name AS last_file,
           submission_date AS last_time,
           username AS last_submitter
    FROM A1AssignmentGroupSubmissions outer_table
    WHERE submission_date = (
        SELECT MAX(submission_date)
        FROM A1AssignmentGroupSubmissions
        WHERE outer_table.assignment_id = assignment_id
            AND outer_table.group_id = group_id
    ) OR submission_date IS NULL -- include groups with no submissions
);

-- Cross product these two tables, joined on assignment_id and group_id
CREATE VIEW FirstLastSubmissionsPerGroup AS (
    SELECT first.group_id,
           first_file,
           first_time,
           first_submitter,
           last_file,
           last_time,
           last_submitter,
           last_time - first_time AS elapsed_time
    FROM FirstSubmissionsPerGroup first JOIN LastSubmissionsPerGroup last
        ON first.group_id = last.group_id
);

-- Final answer.
INSERT INTO q6 (SELECT * FROM FirstLastSubmissionsPerGroup);
