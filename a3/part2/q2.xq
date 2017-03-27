let $important := fn:doc("q2.dtd")
let $reqSkill := $important//reqSkill
let $levelImportantProduct := 
	for $skill in $reqSkill
		let $product := xs:integer($skill/@level) * xs:integer($skill/@importance)
		return $product
let $maxLevelImportantProduct := fn:max($levelImportantProduct)
let $postings := $important//posting
let $maxPostings :=
	for $p in $postings
		where count($p/reqSkill[xs:integer(@level) * xs:integer(@importance) = $maxLevelImportantProduct]) > 0
		return $p
	
return <important> { $maxPostings } </important>
