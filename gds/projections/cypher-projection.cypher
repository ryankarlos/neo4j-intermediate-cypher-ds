
// Create a cypher projection representing all User nodes that have rated a
// Movie with a release year greater than 2014. Only include RATED relationships
// with ratings greater than or equal to 4 stars.

CALL gds.graph.project.cypher(
  'movie-ratings-after-2014',
  'MATCH (n) WHERE n:User or n:Movie RETURN id(n) AS id, labels(n) AS labels',
 // alternatively could also use union in node query to get movie and user nodes
  // 'MATCH (u:User) RETURN id(u) AS id, labels(u) AS labels
  // UNION MATCH (m:Movie) WHERE m.year > 2014 RETURN id(m) AS id, labels(m) AS labels'
  '
    MATCH (u:User)-[r:RATED]->(m:Movie)
    WHERE r.rating >= 4 AND m.year > 2014
    RETURN id(u) AS source,
        id(m) AS target,
        r.rating AS rating,
        "RATED" AS type
  '
)
YIELD nodeCount, relationshipCount

//  nodeCount	relationshipCount
//   9796	           282
