let $dbjobs := fn:doc("posting.xml")
(: Find all postings with SQL level 5 as a required skill :)
let $matchingPostings := $dbjobs//posting[reqSkill[@what="SQL" and @level="5"]]
(: wrap these postings in a dbjobs element :)
return <dbjobs> { $matchingPostings } </dbjobs>
