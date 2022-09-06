// ------------------------- Ordering returned results -------------

// Write and execute a query to return the movie titles where they are ordered from the highest to the lowest imdbRating value. In your query, only return movies that have a value for the imdbRating property.
// 9058 rows returned, 9.6 is highest rating

MATCH (m:Movie)
WHERE m.imdbRating IS NOT NULL
RETURN m.title, m.imdbRating AS rating
ORDER BY rating DESC
LIMIT 1


// Using the answer from query above, write another query to find the youngest actor that acted in the most highly-rated movie?
// should return Scott Grimes

MATCH (p:Person)-[:ACTED_IN]-(m:Movie)
WHERE p.born IS NOT NULL
AND m.imdbRating = 9.6
RETURN DISTINCT p.name, p.born
ORDER BY p.born DESC
LIMIT 1


// returns the names of pair of people, one of who acted or directed the movie Toy Story and the other who also acted in the same movie.
// remove duplicates and should return 166 rows

MATCH (p:Person)-[:ACTED_IN| DIRECTED]->(m)
WHERE m.title = 'Toy Story'
MATCH (p)-[:ACTED_IN]->()<-[:ACTED_IN]-(p2:Person)
RETURN  DISTINCT p.name, p2.name


// --------------------- map projections tp return data -----------------------------------------

// return all person name containing the word Thomas and return name and date of birth as map

MATCH (p:Person)
WHERE p.name CONTAINS "Thomas"
RETURN p { .name, .born } AS person
ORDER BY p.name


