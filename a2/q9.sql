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
DROP VIEW IF EXISTS AllStudentUsernames CASCADE;
DROP VIEW IF EXISTS AllStudentPairs CASCADE;
DROP VIEW IF EXISTS PairableGroups CASCADE;
DROP VIEW IF EXISTS StudentPairsPairableGroups CASCADE;
DROP VIEW IF EXISTS InseparableHalfPairs CASCADE;
DROP VIEW IF EXISTS InseparablePairs CASCADE;
DROP VIEW IF EXISTS DedupedInseparablePairs CASCADE;

-- Define views for your intermediate steps here.
-- Create every (student1, student2) username pair from usernames who have belonged to a group
CREATE VIEW AllStudentUsernames AS (
    SELECT DISTINCT username
    FROM Membership
);

-- Will contain (s1_username, s2_username) and (s2_username, s1_username) pairs
CREATE VIEW AllStudentPairs AS (
    SELECT s1.username AS s1_username, s2.username as s2_username
    FROM AllStudentUsernames s1 CROSS JOIN AllStudentUsernames s2
    WHERE s1.username <> s2.username
);

-- List all group_ids for assignments that had max_group_size >= 2
CREATE VIEW PairableGroups AS (
    SELECT group_id
    FROM Assignment a
        JOIN AssignmentGroup ag
            ON a.assignment_id = ag.assignment_id
    WHERE group_max >= 2
);

-- Join Student1 to all of their Pairable groups
CREATE VIEW StudentPairsPairableGroups AS (
    SELECT s1_username, m.group_id, s2_username
    FROM AllStudentPairs asp
        JOIN Membership m
            ON asp.s1_username = m.username
        JOIN PairableGroups pg
            ON m.group_id = pg.group_id
);


-- Find student pairs that don't meet the criteria
CREATE VIEW SeparablePairs AS (
    SELECT s1_username, s2_username
    FROM StudentPairsPairableGroups sppg
    WHERE NOT EXISTS (SELECT m.group_id -- s1 and s2 both belong to that group
                      FROM Membership m
                      WHERE m.username = sppg.s2_username
                          AND m.group_id = sppg.group_id)
);

-- For every group that s1_username was in, ensure that s2_username was also in that group. If not, remove that pair
CREATE VIEW InseparablePairs AS (
    SELECT s1_username, s2_username FROM AllStudentPairs
    EXCEPT
    SELECT s1_username, s2_username FROM SeparablePairs -- Remove (s1,s2)
    EXCEPT
    SELECT s2_username, s1_username FROM SeparablePairs -- Remove (s2,s1), relation must be symmetric
);

-- Keep only the pairs where s1_username < s2_username alphabetically
CREATE VIEW DedupedInseparablePairs AS (
    SELECT s1_username, s2_username
    FROM InseparablePairs
    WHERE s1_username < s2_username
);

-- Final answer.
INSERT INTO q9 (
    SELECT s1_username AS student1,
           s2_username AS student2
    FROM DedupedInseparablePairs
);
