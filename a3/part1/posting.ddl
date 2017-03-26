Postings = {
	pID = PRIMARY KEY
	position = STRING NOT NULL
} Trigger on ReqSkills insert to ensure a posting has a req skill?

ReqSkills = {
	pID = FOREIGN KEY to Postings
	what = (SQL|Scheme|Python|R|LaTeX) NOT NULL
	importance = (1|2|3|4|5) NOT NULL
} NEEDS TRIGGER

Questions = {
	pID = FOREIGN KEY NOT NULL
	qID = PRIMARY KEY
	question = STRING NOT NULL
}
