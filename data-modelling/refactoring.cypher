// ------------------ Adding Labels in graph ------------------


// Execute this query for profiling.
// we see that 5 Person rows are returned in the fitst step.

PROFILE MATCH (p:Person)-[:ACTED_IN]-()
WHERE p.born < '1950'
RETURN p.name

// Execute this Cypher code to add the Actor label to the appropriate nodes
// There are 5 Person nodes in the graph, but only 4 have an :ACTED_IN relationship. Therefore,
// the query above should apply the Actor label to four of the five Person nodes.

MATCH (p:Person)
WHERE exists ((p)-[:ACTED_IN]-())
SET p:Actor

// Now that we have refactored the graph, we must change our query and profile again.
//Execute this query for profiling. In the first step of this query, we see that 4 Actor rows are returned.

PROFILE MATCH (p:Actor)-[:ACTED_IN]-()
WHERE p.born < '1950'
RETURN p.name


// Run a query to add a label for the Person nodes that have the outgoing relationship of DIRECTED to be labeled Director.
// The new label will be Director. Your code should add 2 labels to the graph.

MATCH (p:Person)
WHERE exists ((p)-[:DIRECTED]-())
SET p:Director

// After refactoring the graph, you must test any use cases that are affected.
// Use case: What person directed a movie ?
// It should return Danny DeVito, for movie title Hoffa.

MATCH (p:Person)-[:DIRECTED]-(m:Movie)
WHERE m.title = 'Hoffa'
RETURN  p.name AS Director