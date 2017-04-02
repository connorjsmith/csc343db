let $interviews := fn:doc("interview.xml")/interviews/interview
let $resumes := fn:doc("resume.xml")/resumes/resume
let $bestForAllInterviews :=
    for $i in $interviews
        let $interviewerID := data($i/@sID)
        let $resumeID := data($i/@rID)
        let $resumeForename := $resumes[@rID=$resumeID]/identification/forename/text()
        let $positionID := data($i/@pID)
        let $skills := $i/assessment/(techProficiency|communication|enthusiasm|collegiality)
        let $skillValues :=
            for $skill in $skills
            return xs:integer($skill/text())
        let $maxSkillValue := max($skillValues)
        let $bestSkillsForInterview :=
            for $skill in $skills
            where xs:integer($skill/text()) = $maxSkillValue
            return <best resume="{$resumeForename}" position="{$positionID}"> { $skill } </best>
        return $bestSkillsForInterview
return <bestskills> { $bestForAllInterviews } </bestskills>
