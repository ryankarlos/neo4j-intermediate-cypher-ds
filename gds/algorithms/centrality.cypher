
/// These examples use the Neo4j movies dataset
// find the people who have directed the most movies
// First create the graph projection.
CALL gds.graph.project('movies', ['Person','Movie'], 'DIRECTED');
// Then stream the degree centrality.
CALL gds.degree.stream('movies')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS director, toInteger(score) AS numberOfMoviesDirected
ORDER BY numberOfMoviesDirected DESC
LIMIT 5

// ---------------------------------------------------------------------------------


// Below is an example of applying PageRank to find the most influential persons in the Director → Actor network
// from movies released on or after 1990 with a revenue of at least 10 Million dollars.
// First, create the graph projection. We can use a Cypher projection in this case to obtain a graph where
// we have (Person)-[:DIRECTED_ACTOR]→(Person). this graph can be traversed to understand the influence across
// directors and actors.
//drop last graph projection
CALL gds.graph.drop('proj', false);
//create Cypher projection for network of people directing actors
//filter to recent high grossing movies
CALL gds.graph.project.cypher(
  'proj',
  'MATCH (a:Person) RETURN id(a) AS id, labels(a) AS labels',
  'MATCH (a1:Person)-[:DIRECTED]->(m:Movie)<-[:ACTED_IN]-(a2)
   WHERE m.year >= 1990 AND m.revenue >= 10000000
   RETURN id(a1) AS source , id(a2) AS target, count(*) AS actedWithCount,
    "DIRECTED_ACTOR" AS type'
);
// Next stream PageRank to find the top 5 most influential people in director-actor network.
CALL gds.pageRank.stream('proj')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS personName, score AS influence
ORDER BY influence DESCENDING, personName LIMIT 5