
// Write a query to return the name of the actor (Clint Eastwood) and all the movies that he acted in that
// contain the string 'high'.

WITH  'Clint Eastwood' AS a, 'high' AS t
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WITH  p, m, toLower(m.title) AS movieTitle
WHERE p.name = a
AND movieTitle CONTAINS t
RETURN p.name AS actor, m.title AS movie

// movieTitle is created during the query and is passed down for use in the WHERE clause. In order to use the variables
// p and m, they must also be included. If you do not include both p and m in the WITH clause (which re-scopes variables)
// these variables cannot be used later in the query and in the RETURN clause.


// Add a WITH clause to this query so that the movie with the highest revenue is returned:

WITH  'Tom Hanks' AS theActor
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = theActor
AND m.revenue IS NOT NULL
WITH m, m.revenue as revenue, m.title AS title
ORDER BY revenue DESC
LIMIT 1
RETURN revenue, title


// Consider the following query

MATCH (n:Movie)
WHERE n.imdbRating IS NOT NULL and n.poster IS NOT NULL
ORDER BY n.imdbRating DESC LIMIT 4
RETURN collect(n)

// Modify this query by adding a WITH clause that customizes the data returned for each Movie node to include:
// title, imdbRating, List of actor names, List of Genre names
// What actor is in more than one of these top 4 movies?

MATCH (n:Movie)
WHERE n.imdbRating IS NOT NULL AND n.poster IS NOT NULL
WITH n {
  .title,
  .imdbRating,
  actors: [ (n)<-[:ACTED_IN]-(p) | p { tmdbId:p.imdbId, .name } ],
  genres: [ (n)-[:IN_GENRE]->(g) | g {.name}]
}
ORDER BY n.imdbRating DESC
LIMIT 4
RETURN collect(n)



