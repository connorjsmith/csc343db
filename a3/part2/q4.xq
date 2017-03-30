let $interviews := fn:doc("interview.xml")/interview
let $interviewers := fn:doc("interview.xml")/interviewer
let $resumes := fn:doc("resume.xml")
let $best = 
	for $i in $interviews
		$interviewerID := $i/@sID/data()
		$resumeID := $i/@rID/data()
		$positionID := $1/@pID/data()
		$skills := $i/assessment/techProficiency|communication|enthusiasm|collegiality
		$maxSkillValue := fn:max(xs:integer(skills/text()))
		$bestSkills := 
			for $skill in $skills
			where xs:integer($skill/text()) = $maxSkillValue
			return $skill
		return <best resume=$resumeID position=$positionID> { $bestSkills } </best>
return <bestskills> { $best } </bestskills>
