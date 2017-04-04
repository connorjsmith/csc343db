DROP SCHEMA IF EXISTS InterviewXML CASCADE;
CREATE SCHEMA InterviewXML;
SET search_path TO InterviewXML;


CREATE DOMAIN AssessmentScore AS INTEGER -- TODO do we need the not null constraint?
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
    PRIMARY KEY (rID, postingID, dateTime) -- can only interview one resume holder for one position at a time
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
    UNIQUE (rID, postingID, qID), -- don't let a resume holder give more than one answer to a posting's question
    FOREIGN KEY (rID, postingID, dateTime) REFERENCES Interview
);
