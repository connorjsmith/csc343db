-- TODO: Write additional constraints / unenforceable stuff from dtd, assumptions
-- TODO write cascades for removals

-- TODO: Remove these
DROP SCHEMA IF EXISTS ResumeXML CASCADE;
CREATE SCHEMA ResumeXML;
SET search_path TO ResumeXML;



CREATE TABLE Identification (
    pID INTEGER PRIMARY KEY,
    forename TEXT NOT NULL,
    surname TEXT NOT NULL,
    DOB DATE NOT NULL,
    citizenship TEXT NOT NULL,
    address TEXT NOT NULL,
    telephone TEXT NOT NULL, -- TODO: text or var char for correct number of digits?
    email TEXT NOT NULL
);

CREATE TABLE Resume (
    rID INTEGER PRIMARY KEY,
    pID INTEGER REFERENCES Identification NOT NULL
);

CREATE TABLE Summary (
    rID INTEGER REFERENCES Resume NOT NULL,
    Summary TEXT NOT NULL
);

CREATE TABLE Honorific (
    pID INTEGER REFERENCES Identification NOT NULL,
    honorific TEXT NOT NULL
);

CREATE TABLE PersonTitles (
    pID INTEGER REFERENCES Identification NOT NULL,
    title TEXT NOT NULL
);


CREATE TYPE DegreeLevelType AS ENUM('certificate', 'undergraduate', 'professional', 'masters', 'doctoral');

CREATE TABLE Degree (
    degreeID INTEGER PRIMARY KEY,
    degreeName TEXT NOT NULL,
    degreeLevel DegreeLevelType NOT NULL,
    institution TEXT NOT NULL,
    honors BOOLEAN NOT NULL,
    startPeriod DATE NOT NULL,
    endPeriod DATE NOT NULL -- though really this could be null if it is on-going
);

CREATE TABLE Education (
    rID INTEGER REFERENCES Resume NOT NULL,
    degreeID INTEGER REFERENCES Degree NOT NULL
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
    level SkillLevelType
);

CREATE TABLE Position (
    positionID INTEGER PRIMARY KEY,
    "where" TEXT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL
);

CREATE TABLE PositionTitle (
    positionID INTEGER REFERENCES Position NOT NULL,
    title TEXT NOT NULL
);

CREATE TABLE PositionDescription (
    positionID INTEGER REFERENCES Position NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE Experience (
    rID INTEGER REFERENCES Resume NOT NULL,
    positionID INTEGER references Position NOT NULL
);
