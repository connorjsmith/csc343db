-- TODO: Write additional constraints / unenforceable stuff from dtd, assumptions
-- TODO write cascades for removals

-- TODO: Remove these
DROP SCHEMA IF EXISTS ResumeXML CASCADE;
CREATE SCHEMA ResumeXML;
SET search_path TO ResumeXML;

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
    UNIQUE(personID) -- According to Piazza @642, a person can only have one resume
);

CREATE TABLE Summary (
    rID INTEGER REFERENCES Resume UNIQUE NOT NULL, -- don't let a resume have more than one summary
    Summary TEXT NOT NULL
);

CREATE TABLE Honorific (
    personID INTEGER REFERENCES Identification NOT NULL,
    honorific TEXT NOT NULL,
    UNIQUE(personID, honorific) -- don't let a person have duplicate honorifics
);

CREATE TABLE PersonTitles (
    personID INTEGER REFERENCES Identification NOT NULL,
    title TEXT NOT NULL,
    UNIQUE(personID, title) -- don't let a person have duplicate titles

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
CREATE DOMAIN SkillLevelType AS INTEGER -- TODO do i need a not null check on domains?
    check (value >= 1 AND value <= 5);

CREATE TABLE Skill (
    rID INTEGER REFERENCES Resume NOT NULL,
    what SkillWhatType NOT NULL,
    level SkillLevelType,
    UNIQUE(rID, what) -- don't allow a skill to be repeated twice for a resume
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
    UNIQUE(positionID, title) -- don't let a position have duplicate titles
);

CREATE TABLE PositionDescription (
    positionID INTEGER REFERENCES Position UNIQUE NOT NULL, -- don't let a position have more than one description
    description TEXT NOT NULL
);
