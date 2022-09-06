
// Write and execute a query to determine the highest average rating by a user for a Tom Hanks Movie.
// Use avg(r.rating) to aggregate the rating values for all movies that Tom Hanks acted in, where
// you use the pattern (m:Movie)←[r:RATED]-(:User).
// What Tom Hanks movie had the highest average rating?
// Answer - Captain Phillips (rating 4.2)

WITH "Tom Hanks" AS Actor
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)<-[r:RATED]-(:User)
WHERE p.name = Actor
WITH m, avg(r.rating) AS rating
ORDER BY rating DESC
LIMIT 1
RETURN m.title, rating


// modify the query below to  return the number of movies released in each country.

MATCH (m:Movie)
UNWIND m.languages AS lang
WITH m, trim(lang) AS language
// this automatically, makes the language distinct because it's a grouping key
WITH language, collect(m.title) AS movies
RETURN language, movies[0..10]


// How many movies released in the UK and Taiwan ?
// UK(1386) , Taiwan(17)

MATCH (m:Movie)
UNWIND m.countries AS country
WITH m, trim(country) AS country
WITH country, collect(m.title) AS movies
WHERE country = "UK" OR country = "Taiwan"
RETURN country, size(movies) AS num_movies