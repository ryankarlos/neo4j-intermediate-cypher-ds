

// write a query to return the number of movies a person directed.
// What is the highest number of movies a director directed in our graph?
// Woody ALlen - 42

MATCH (p:Person)-[:DIRECTED]-(m:Movie)
RETURN p.name , count(*) AS total
ORDER by total DESC


// Write and execute a query to return the list of actors for each movie. Order and limit the results so that the movie with the largest cast is returned.
// What movie had the largest list of actors?
// Hamlet - 24 cast

MATCH (p:Person)-[:ACTED_IN]-(m:Movie)
RETURN m.title AS title , size(collect(p)) AS cast_size
ORDER by cast_size DESC
LIMIT 1
