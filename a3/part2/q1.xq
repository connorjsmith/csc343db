declare variable $dataset0 external;
(: Find all postings with SQL level 5 as a required skill :)
let $matchingPostings := $dataset0//posting[reqSkill[@what="SQL" and @level="5"]]
(: wrap these postings in a dbjobs element :)
return <dbjobs> { $matchingPostings } </dbjobs>
