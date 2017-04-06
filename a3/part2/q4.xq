declare variable $dataset0 external; (: interview.xml :)
declare variable $dataset1 external; (: resume.xml :)

let $interviews := $dataset0/interviews/interview
let $resumes := $dataset1/resumes/resume
let $bestForAllInterviews :=
    for $i in $interviews
        let $resumeID := data($i/@rID)
        let $resumeForename := $resumes[@rID=$resumeID]/identification/name/forename/text()
        let $positionID := data($i/@pID)
        let $skills := $i/assessment/(communication|enthusiasm|collegiality)
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
