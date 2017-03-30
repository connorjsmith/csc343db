let $resume := fn:doc("resume.xml")
(: TODO we can probably refactor this step out and use a where in the FOR statement :)
let $ThreeSkillPlusResumes := $resume//resume[fn:count(skills) >= 3]
let $QualifiedCandidates := 
    for $r in $ThreeSkillPlusResumes
        let $candidateForename := $r/identification/forename/text()
        let $rID := $r/@rID/data()
        let $citizenship := $r/identification/citizenship/text()
        let $numSkills := fn:count($r/skills)
        return 
            <candidate rid=$rID 
                       numskills=$numSkills 
                       citizenship=$citizenship>
                <name> {$candidateForename} </name>
            </candidate>
(: Report the required information about each candidate :)

return <qualified> { $QualifiedCandidates } </qualified>

