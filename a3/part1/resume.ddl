Resumes = {
	rID = PRIMARY KEY
	personID = FOREIGN KEY NOT NULL
}

Summaries = {
	rID = FOREIGN KEY, UNIQUE NOT NULL
	Summary = TEXT, NOT NULL
}

Identification = {
	personID = FOREIGN KEY to Names, UNIQUE NOT NULL
	sex
	DOB = Date (NULLABLE?)
	citizenship = NULLABLE STRING
	address = NULLABLE string
	telephone = NULLABLE string
	email = NULLABLE string (TODO: maybe this can be the primary key?)
}

Names = {
	personID = PRIMARY KEY
	forename = STRING NOT NULL
	surname = STRING NOT NULL
}

Honorifics = {
	personID = FOREIGN KEY to Names, not unique NOT NULL
	Honorific = STRING
} NEED A TRIGGER TO ENSURE A PERSON HAS AN Honorific, order of enforcement?

PersonTitles = {
	personID = FOREIGN KEY to Names, not unique NOT NULL
	Title = STRING
} NO TRIGGER NEEDED

Education = {
	rID = FOREIGN KEY to Resumes (TODO: because education can be left off a resume) NOT NULL
	degreeID = FOREIGN KEY to Degrees NOT NULL
} PRIMARY KEY = (rID, degreeID)


Degrees = {
	degreeID = primary key
	degreeName = STRING NOT NULL
	degreeLevel = STRING(cert|undergraduate|professional|masters|doctoral) NOT NULL
	institution = STRING NOT NULL (TODO: institution ID?)
	honors = BOOLEAN NOT NULL
	startPeriod = Date not null
	endPeriod = Date (nullable for inprogress?)
}

Majors = {
	degreeID = FOREIGN KEY to Degrees NOT NULL
	major = STRING NOT NULL
}

Minors = {
	degreeID = FOREIGN KEY to Degrees NOT NULL
	minor = STRING NOT NULL
}

Experiences = {
	rID = FOREIGN KEY to Resumes (TODO: same as Education) NOT NULL
	positionID = FOREIGN KEY TO Positions NOT NULL
} PRIMARY KEY = (rID, experienceID)

Positions = {
	positionID = PRIMARY KEY
	description = NULLABLE STRING
	where = STRING NOT NULL
	startDate = DATE not null (TODO not null?)
	endDate = DATE not null ("""")
}
	
JobTitles = {
	positionID = FOREIGN KEY to Positions, not unique NOT NULL
	Title = STRING
} TRIGGER NEEDED

Skills = {
	rID = FOREIGN KEY to Resumes NOT NULL
	what = (SQL|Scheme|Python|R|LaTeX) NOT NULL
	level = (1|2|3|4|5)
} NEED TRIGGER ON INSERT

