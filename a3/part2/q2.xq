declare variable $dataset0 external;
let $reqSkill := $dataset0//reqSkill
let $levelImportantProduct := 
	for $skill in $reqSkill
		let $product := xs:integer($skill/@level) * xs:integer($skill/@importance)
		return $product
let $maxLevelImportantProduct := fn:max($levelImportantProduct)
let $postings := $dataset0//posting
let $maxPostings :=
	for $p in $postings
		where count($p/reqSkill[xs:integer(@level) * xs:integer(@importance) = $maxLevelImportantProduct]) > 0
		return $p
	
return <important> { $maxPostings } </important>
