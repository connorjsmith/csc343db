-- Count not enforce constraints:
--    1. one or more titles associated with a position
--        <!ELEMENT position (title+,description?,period)>
--    2. one or more majors associated with a degree
--        <!ELEMENT degree (degreeName,institution,major+,minor*,honours?,period)>
--    3. one or more honorifics associated with a name
--        <!ELEMENT name (forename,surname,honorific+,title*)>
--    4. one or more reqSkill associated with a posting
--        <!ELEMENT posting (position,reqSkill+,questions*)>
--    5. one or more interviewers and one or more interviews
--        <!ELEMENT interviews (interview+, interviewer+)>
--    6. one or more honorifics associated with an interviewer
--        <!ELEMENT interviewer (forename,surname,honorific+,title*)>

-- Resume.dtd
CREATE TABLE Identification (
    personID INTEGER PRIMARY KEY,
    forename TEXT NOT NULL,
    surname TEXT NOT NULL,
    DOB DATE NOT NULL,
    citizenship TEXT NOT NULL,
    address TEXT NOT NULL,
    telephone TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);

CREATE TABLE Resume (
    rID INTEGER PRIMARY KEY,
    personID INTEGER REFERENCES Identification NOT NULL, 
    UNIQUE(personID) -- Additional Constraint: According to Piazza @642, a person can only have one resume
);

CREATE TABLE Summary (
    rID INTEGER REFERENCES Resume UNIQUE NOT NULL, -- Additional Constraint: don't let a resume have more than one summary
    Summary TEXT NOT NULL
);

CREATE TABLE Honorific (
    personID INTEGER REFERENCES Identification NOT NULL,
    honorific TEXT NOT NULL,
    UNIQUE(personID, honorific) -- Additional Constraint: don't let a person have duplicate honorifics
);

CREATE TABLE PersonTitles (
    personID INTEGER REFERENCES Identification NOT NULL,
    title TEXT NOT NULL,
    UNIQUE(personID, title) -- Additional Constraint: don't let a person have duplicate titles

);

CREATE TYPE DegreeLevelType AS ENUM('certificate', 'undergraduate', 'professional', 'masters', 'doctoral');
CREATE TABLE Degree (
    degreeID INTEGER PRIMARY KEY,
    degreeName TEXT NOT NULL,
    degreeLevel DegreeLevelType NOT NULL,
    institution TEXT NOT NULL,
    honors BOOLEAN NOT NULL,
    startPeriod DATE NOT NULL,
    endPeriod DATE NOT NULL, -- though really this could be null if it is on-going
    rID INTEGER REFERENCES Resume NOT NULL
);

CREATE TABLE Major (
    degreeID INTEGER REFERENCES Degree NOT NULL,
    major TEXT NOT NULL
);

CREATE TABLE Minor (
    degreeID INTEGER REFERENCES Degree NOT NULL,
    minor TEXT NOT NULL
);

CREATE TYPE SkillWhatType AS ENUM('SQL', 'Scheme', 'Python', 'R', 'LaTeX');
CREATE DOMAIN SkillLevelType AS INTEGER
    check (value >= 1 AND value <= 5);

CREATE TABLE Skill (
    rID INTEGER REFERENCES Resume NOT NULL,
    what SkillWhatType NOT NULL,
    level SkillLevelType NOT NULL,
    UNIQUE(rID, what) -- Additional Constraint: don't allow a skill to be repeated twice for a resume
);

CREATE TABLE Position (
    positionID INTEGER PRIMARY KEY,
    rID INTEGER REFERENCES Resume NOT NULL,
    "where" TEXT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL
);

CREATE TABLE PositionTitle (
    positionID INTEGER REFERENCES Position NOT NULL,
    title TEXT NOT NULL,
    UNIQUE(positionID, title) -- Additional Constraint: don't let a position have duplicate titles
);

CREATE TABLE PositionDescription (
    positionID INTEGER REFERENCES Position UNIQUE NOT NULL, -- don't let a position have more than one description
    description TEXT NOT NULL
);

-- posting.dtd
CREATE TABLE Posting (
    postingID INTEGER PRIMARY KEY,
    position TEXT NOT NULL
);

CREATE DOMAIN SkillImportanceType AS INTEGER
    check (value >= 1 AND value <= 5);

CREATE TABLE ReqSkill (
    postingID INTEGER REFERENCES Posting NOT NULL,
    what SkillWhatType NOT NULL,
    importance SkillImportanceType NOT NULL,
    UNIQUE(postingID, what) -- Additional Constraint: don't let a posting list the same skill twice
);

CREATE TABLE Question (
    qID INTEGER PRIMARY KEY,
    postingID INTEGER REFERENCES Posting NOT NULL,
    question TEXT NOT NULL
);

-- interview.dtd
CREATE TABLE Interviewer (
    sID INTEGER PRIMARY KEY,
    forename TEXT NOT NULL,
    surname TEXT NOT NULL
);

CREATE DOMAIN AssessmentScore AS REAL
    check (value >= 0 AND value <= 100);
CREATE TABLE Interview (
    rID INTEGER REFERENCES Resume NOT NULL,
    postingID INTEGER REFERENCES Posting NOT NULL,
    sID INTEGER REFERENCES Interviewer NOT NULL,
    dateTime TIMESTAMP NOT NULL,
    location TEXT NOT NULL,
    techProficiency AssessmentScore NOT NULL,
    communication AssessmentScore NOT NULL,
    enthusiasm AssessmentScore NOT NULL,
    collegiality AssessmentScore, -- nullable
    PRIMARY KEY (rID, postingID, dateTime) -- Additional Constraint: can only interview one resume holder for one position at a time, no "double booking" with the exact same start/end date
);

CREATE TABLE InterviewerTitle (
    sID INTEGER REFERENCES Interviewer NOT NULL,
    title TEXT NOT NULL,
    UNIQUE(sID, title) -- Additional Constraint: don't let an interviewer have duplicate titles
);

CREATE TABLE InterviewerHonorific (
    sID INTEGER REFERENCES Interviewer NOT NULL,
    honorific TEXT NOT NULL,
    UNIQUE(sID, honorific) -- Additional Constraint: don't let an interviewer have duplicate honorifics
);

CREATE TABLE Answer (
    rID INTEGER NOT NULL,
    postingID INTEGER NOT NULL,
    dateTime TIMESTAMP NOT NULL,
    qID INTEGER REFERENCES Question NOT NULL,
    answer TEXT NOT NULL,
    UNIQUE (rID, postingID, qID), -- Additional Constraint: don't let a resume holder give more than one answer to a posting's question
    FOREIGN KEY (rID, postingID, dateTime) REFERENCES Interview
);
