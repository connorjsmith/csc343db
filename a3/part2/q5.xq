declare variable $dataset0 external; (: posting.xml :)
declare variable $dataset1 external; (: resume.xml :)

let $postingSkills := $dataset0//reqSkill/@what
let $resumeSkills := $dataset1//skill
let $skillTypes := fn:distinct-values(data($postingSkills)) (: Strip whitespace? :)
let $histogram := 
	for $skillType in $skillTypes
		let $resumeSkillsOfThisType := $resumeSkills[@what=$skillType]
		let $counts := 
			for $level in 1 to 5
				let $skillCount := fn:count($resumeSkillsOfThisType[@level=$level])
				return <count level="{$level}" n="{$skillCount}" />
		return <skill name="{$skillType}"> { $counts } </skill>
return <histogram> {$histogram} </histogram>
