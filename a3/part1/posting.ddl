-- TODO remove this
DROP SCHEMA IF EXISTS PostingXML CASCADE;
CREATE SCHEMA PostingXML;
SET search_path TO PostingXML;

CREATE TABLE Posting (
    postingID INTEGER PRIMARY KEY,
    position TEXT NOT NULL
);

CREATE TYPE SkillWhatType AS ENUM('SQL', 'Scheme', 'Python', 'R', 'LaTeX'); -- TODO: remove this

CREATE DOMAIN SkillImportanceType AS INTEGER
    check (value >= 1 AND value <= 5);

CREATE TABLE ReqSkill (
    postingID INTEGER REFERENCES Posting NOT NULL,
    what SkillWhatType NOT NULL,
    importance SkillImportanceType NOT NULL,
    UNIQUE(pID, what) -- don't let a posting list the same skill twice
);

CREATE TABLE Question (
    qID INTEGER PRIMARY KEY,
    postingID INTEGER REFERENCES Posting NOT NULL,
    question TEXT NOT NULL
);
