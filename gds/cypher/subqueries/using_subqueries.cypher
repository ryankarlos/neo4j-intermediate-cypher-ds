// Write and execute the subquery to return the movie nodes that have a countries list element of 'France'.
// How many movies were in the largest Genre category for movies released in France?

// You must pass in the g variable to the subquery.
// You must test if the movie node for that genre was released in France.
// The subquery must return the count of the movie nodes, numMovies for each Genre passed in.

// Answer - 277 movies

MATCH (g:Genre)
CALL
{
WITH g
MATCH (g)-[]-(m:Movie)
WHERE 'France' in m.countries
RETURN count(m) AS numMovies
}
RETURN g.name AS genre, numMovies
ORDER BY numMovies DESC


// we have a query below which returns actor information for year 2015

MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE m.year = 2015
RETURN "Actor" AS type,
p.name AS workedAs,
collect(m.title) AS movies

// Now add another query to this code to return the directors for 2015. Use UNION ALL to combine results.
// The second query will return the string "Director" as Type.
// How many rows are returned?
// 819 rows

MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE m.year = 2015
RETURN "Actor" AS type,
p.name AS workedAs,
collect(m.title) AS movies
UNION ALL
MATCH (m:Movie)<-[:DIRECTED]-(p:Person)
WHERE m.year = 2015
RETURN "Director" AS type,
p.name AS workedAs,
collect(m.title) AS movies