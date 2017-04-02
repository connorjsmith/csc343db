let $resume := fn:doc("resume.xml")
(: TODO we can probably refactor this step out and use a where in the FOR statement :)
let $QualifiedCandidates := 
    for $r in $resume//resume
        let $candidateForename := $r//forename/text()
        let $rID := data($r/@rID)
        let $citizenship := $r/identification/citizenship/text()
        let $numSkills := fn:count($r/skills/skill)
	where $numSkills >= 3
        return 
            <candidate rid="{$rID}"
                       numskills="{$numSkills}"
                       citizenzhip="{$citizenship}">
                <name> {$candidateForename} </name>
            </candidate>
return <qualified> { $QualifiedCandidates } </qualified>
