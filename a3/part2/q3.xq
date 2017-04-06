declare variable $dataset0 external;
let $QualifiedCandidates := 
    for $r in $dataset0//resume
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
