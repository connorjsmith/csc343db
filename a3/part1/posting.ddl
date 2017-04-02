-- TODO remove this
DROP SCHEMA IF EXISTS PostingXML CASCADE;
CREATE SCHEMA PostingXML;
SET search_path TO PostingXML;

CREATE TABLE Posting (
    pID INTEGER PRIMARY KEY,
    position TEXT NOT NULL
);

CREATE DOMAIN SkillImportanceType AS INTEGER
    check (value >= 1 AND value <= 5);

CREATE TYPE SkillWhatType AS ENUM('SQL', 'Scheme', 'Python', 'R', 'LaTeX'); -- TODO: remove this
CREATE TABLE ReqSkill (
    pID INTEGER REFERENCES Posting NOT NULL,
    what SkillWhatType NOT NULL,
    importance SkillImportanceType NOT NULL
);

CREATE TABLE Question (
    qID INTEGER PRIMARY KEY,
    postingID INTEGER REFERENCES Posting NOT NULL,
    question TEXT NOT NULL
);
