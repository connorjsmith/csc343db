let $skills := fn:doc("resume.xml")//skill
let $skillTypes := fn:unique($skills/@what/text()) (: Strip whitespace? :)
let $histogram := 
	for $skillType in $skillTypes
		let $skillsOfThisType := $skills[@what=$skillType]
		let $counts = for $level in 1 to 5
			let $skillCount = fn:count($skillsOfThisType[@level=$level])
			return <count level=$level n=$skillCount />
		return <skill name=$skillType> { $counts } </skill>
return <histogram> {$histogram} </histogram>
