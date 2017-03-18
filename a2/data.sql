-- If there is already any data in these tables, empty it out.

TRUNCATE TABLE Result CASCADE;
TRUNCATE TABLE Grade CASCADE;
TRUNCATE TABLE RubricItem CASCADE;
TRUNCATE TABLE Grader CASCADE;
TRUNCATE TABLE Submissions CASCADE;
TRUNCATE TABLE Membership CASCADE;
TRUNCATE TABLE AssignmentGroup CASCADE;
TRUNCATE TABLE Required CASCADE;
TRUNCATE TABLE Assignment CASCADE;
TRUNCATE TABLE MarkusUser CASCADE;


-- Now insert data from scratch.

INSERT INTO MarkusUser VALUES ('i1', 'iln1', 'ifn1', 'instructor');
INSERT INTO MarkusUser VALUES ('no_group_instructor', 'no_iln1', 'no_ifn1', 'instructor');
INSERT INTO MarkusUser VALUES ('no_group_TA', 'no_tln1', 'no_tfn1', 'TA');
INSERT INTO MarkusUser VALUES ('s1', 'sln1', 'sfn1', 'student');
INSERT INTO MarkusUser VALUES ('s2', 'sln2', 'sfn2', 'student');
INSERT INTO MarkusUser VALUES ('s3', 'sln3', 'sfn3', 'student');
INSERT INTO MarkusUser VALUES ('s4', 'sln4', 'sfn4', 'student');
INSERT INTO MarkusUser VALUES ('perfect_s1', 'sln5', 'sfn5', 'student');
INSERT INTO MarkusUser VALUES ('perfect_s2', 'sln6', 'sfn6', 'student');
INSERT INTO MarkusUser VALUES ('t1', 'tln1', 'tfn1', 'TA');

INSERT INTO Assignment VALUES (1000, 'A1', '2017-02-08 20:00', 1, 2);
INSERT INTO Assignment VALUES (0, 'orphan_assignment', '2017-02-08 20:00', 1, 2);
INSERT INTO Assignment VALUES (2, 'orphan_assignment2', '2017-02-08 20:00', 1, 2);

INSERT INTO Required VALUES (1000, 'A1.pdf');

INSERT INTO AssignmentGroup VALUES (2000, 1000, 'repo_url');

INSERT INTO Membership VALUES ('s1', 2000);
INSERT INTO Membership VALUES ('s2', 2000);

INSERT INTO Submissions VALUES (3000, 'A1.pdf', 's1', 2000, '2017-02-08 19:59');

INSERT INTO Grader VALUES (2000, 't1');

INSERT INTO RubricItem VALUES (4000, 1000, 'style', 4, 0.25);
INSERT INTO RubricItem VALUES (4001, 1000, 'tester', 12, 0.75);

INSERT INTO Grade VALUES (2000, 4000, 3);
INSERT INTO Grade VALUES (2000, 4001, 9);

INSERT INTO Result VALUES (2000, 7.5, true);


-- Begin my own custom test cases
-- Add an Assignment with no grades associated with it
INSERT INTO Assignment VALUES (1, 'ungraded_assignment', '2017-02-09 20:00', 2, 2);
INSERT INTO AssignmentGroup VALUES (2002, 1, 'repo_url1');
INSERT INTO RubricItem VALUES (4004, 1, 'style-ungraded', 5, 0.75); -- Weighted Divisor of 39.75
INSERT INTO RubricItem VALUES (4005, 1, 'tester-ungraded', 50, 0.75); -- """"
INSERT INTO Membership VALUES ('s3', 2002);

-- Add another Assignment, AssignmentGroup, members, RubricItems, and Grades
INSERT INTO Assignment VALUES (1001, 'A1.1', '2017-02-09 20:00', 1, 2);
INSERT INTO AssignmentGroup VALUES (2001, 1001, 'repo_url1');
INSERT INTO Membership VALUES ('s1', 2001);
INSERT INTO Membership VALUES ('s2', 2001);
INSERT INTO Grader VALUES (2001, 'i1');
INSERT INTO Submissions VALUES (3001, 'A1.1.pdf', 's1', 2001, '2017-02-08 13:59');

-- Also test that this works for total weights > 1.0
INSERT INTO RubricItem VALUES (4002, 1001, 'style-A1.1', 5, 0.75); -- Weighted Divisor of 39.75
INSERT INTO RubricItem VALUES (4003, 1001, 'tester-A1.1', 50, 0.75); -- """"
INSERT INTO Grade VALUES (2001, 4002, 3);
INSERT INTO Grade VALUES (2001, 4003, 20);
INSERT INTO Result VALUES (2001, 17.25, false); -- 3*0.75 + 20*0.75

-- Add a perfect group
INSERT INTO AssignmentGroup VALUES (9999, 1000, 'perf_url');
INSERT INTO Membership VALUES ('perfect_s1', 9999);
-- INSERT INTO Membership VALUES ('perfect_s2', 9999);
INSERT INTO Grade VALUES (9999, 4000, 4);
INSERT INTO Grade VALUES (9999, 4001, 12);
INSERT INTO Result VALUES (9999, 10, true);

-- Add a group with no grades to assignment 1000
INSERT INTO AssignmentGroup VALUES (9998, 1000, 'perf_url');
INSERT INTO MarkusUser VALUES ('null_1000_grade_sA', 'sln9', 'sfn9', 'student');
INSERT INTO MarkusUser VALUES ('null_1000_grade_sZ', 'sln8', 'sfn8', 'student');
INSERT INTO Membership VALUES ('null_1000_grade_sA', 9998);
INSERT INTO Membership VALUES ('null_1000_grade_sZ', 9998);



-- Q6 group with no submissions for A1
INSERT INTO AssignmentGroup VALUES (5000, 1000, 'no_submissions_url');
