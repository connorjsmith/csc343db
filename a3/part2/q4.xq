let $interviews := fn:doc("interview.xml")/interviews/interview
let $interviewers := fn:doc("interview.xml")/interviews/interviewer
let $resumes := fn:doc("resume.xml")
let $bestForAllInterviews :=
	for $i in $interviews
		let $interviewerID := data($i/@sID)
		let $resumeID := data($i/@rID)
		let $positionID := data($i/@pID)
		let $skills := $i/assessment/(techProficiency|communication|enthusiasm|collegiality)
		let $skillValues := 
			for $skill in $skills
			return xs:integer($skill/text())
		let $maxSkillValue := max($skillValues)
		let $bestSkillsForInterview := 
			for $skill in $skills
			where xs:integer($skill/text()) = $maxSkillValue
			return <best resume="{$resumeID}" position="{$positionID}"> { $skill } </best>
		return $bestSkillsForInterview
(: TODO: report the proper information for the person interviewed, validate against q4.dtd :)
return <bestskills> { $bestForAllInterviews } </bestskills>
