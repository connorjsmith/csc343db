Interviews = {
	rID FOREIGN KEY to Resume
	pID FOREIGN KEY to Posting
	sID FOREIGN KEY to Interviewer
	dateTime = DATE not null
	Location = STRING not null
	techProficiency = Number not null
	communication = Number not null
	enthusiasm = Number not null
	collegiality = Number not null
} TRIGGER to ensure numbers 0 <= x <= 100. Primary Key?

Interviwer = {
	TODO: New column in identity table? Add a role as candidate or interviewer?
	otherwise will have to replicate most of the identity relation here
}

Answers = {
	(rID, pID, sID) FOREIGN KEY to Interviews
	qID = FOREIGN KEY to Questions
	answer = STRING not null
}
