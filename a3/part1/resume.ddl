-- TODO: Write additional constraints / unenforceable stuff from dtd, assumptions
-- TODO write cascades for removals

CREATE TABLE Resumes (
    rID integer PRIMARY KEY,
    pID integer REFERENCES Identification NOT NULL
);

CREATE TABLE Summary (
    rID REFERENCES Resumes NOT NULL,
    Summary TEXT NOT NULL
);

CREATE TABLE Identification (
    pID integer PRIMARY KEY,
    forename TEXT NOT NULL,
    surname TEXT NOT NULL,
    DOB DATE NOT NULL,
    citizenship TEXT NOT NULL,
    address TEXT NOT NULL,
    telephone TEXT NOT NULL, -- TODO: text or var char for correct number of digits?
    email TEXT NOT NULL
);

CREATE TABLE Honorific (
    pID REFERENCES Identification NOT NULL,
    honorific TEXT NOT NULL
);

CREATE TABLE PersonTitles (
    pID REFERENCES Identification NOT NULL,
    title TEXT NOT NULL
);

CREATE TABLE Education (
    rID REFERENCES Resume NOT NULL,
    degreeID integer REFERENCES Degree NOT NULL
);


CREATE DOMAIN DegreeLevelType AS TEXT
    check (value in ('certificate', 'undergraduate', 'professional', 'masters', 'doctoral'));

CREATE TABLE Degree (
    degreeID INTEGER PRIMARY KEY,
    degreeName TEXT NOT NULL,
    degreeLevel DegreeLevelType,
    institution TEXT NOT NULL,
    honors BOOLEAN NOT NULL,
    startPeriod DATE NOT NULL,
    endPeriod DATE NOT NULL -- though really this could be null if it is on-going
);

CREATE TABLE Major (
    degreeID INTEGER REFERENCES Degree NOT NULL,
    major TEXT NOT NULL
);

CREATE TABLE Minor (
    degreeID INTEGER REFERENCES Degree NOT NULL,
    minor TEXT NOT NULL
);


CREATE DOMAIN SkillWhatType AS TEXT
    check (value in ('SQL', 'Scheme', 'Python', 'R', 'LaTeX'));

CREATE DOMAIN SkillLevelType AS INTEGER
    check (value >= 1 AND value <= 5);

CREATE TABLE Skill (
    rID INTEGER REFERENCES Resume NOT NULL,
    what SkillWhatType,
    level SkillLevelType,
);

CREATE TABLE Experience (
    rID integer REFERENCES Resume NOT NULL,
    positionID integer references Position NOT NULL
);

CREATE TABLE Position (
    positionID integer PRIMARY KEY,
    where TEXT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL
);

CREATE TABLE PositionTitle (
    positionID integer REFERENCES Position NOT NULL,
    title TEXT NOT NULL
);

CREATE TABLE PositionDescription (
    positionID integer REFERENCES Position NOT NULL,
    description TEXT NOT NULL, -- nullable
);
