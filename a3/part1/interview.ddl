DROP SCHEMA IF EXISTS InterviewXML CASCADE;
CREATE SCHEMA InterviewXML;
SET search_path TO InterviewXML;


CREATE DOMAIN AssessmentScore AS INTEGER
    check (value >= 0 AND value <= 100);

CREATE TABLE Interview (
    rID INTEGER REFERENCES Resume NOT NULL;
    postingID INTEGER REFERENCES Posting NOT NULL;
    sID INTEGER REFERENCES Interviewer NOT NULL;
    dateTime TIMESTAMP NOT NULL,
    location TEXT NOT NULL,
    techProficiency AssessmentScore NOT NULL,
    communication AssessmentScore NOT NULL,
    enthusiasm AssessmentScore NOT NULL,
    collegiality AssessmentScore, -- nullable
    (rID, postingID, dateTime) PRIMARY KEY
);

CREATE TABLE Interviewer (
    sID INTEGER PRIMARY KEY,
    forename TEXT NOT NULL,
    surname TEXT NOT NULL,
);

-- TODO a little redundant?
CREATE TABLE InterviewerTitle (
    sID INTEGER REFERENCES Interviewer NOT NULL,
    title TEXT NOT NULL
);

-- TODO a little redundant?
CREATE TABLE InterviewerHonorific (
    sID INTEGER REFERENCES Interviewer NOT NULL,
    honorific TEXT NOT NULL
);

CREATE TABLE Answer (
    rID INTEGER NOT NULL,
    postingID INTEGER NOT NULL,
    dateTime TIMESTAMP NOT NULL,
    qID INTEGER REFERENCES Question NOT NULL,
    answer TEXT NOT NULL,
    (rID, postingID, qID) UNQIUE,
    (rID, postingID, dateTime) REFERENCES Interview
);
