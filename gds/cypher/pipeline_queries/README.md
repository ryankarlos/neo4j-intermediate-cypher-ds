This section will use the Cypher `WITH` clause to set values and control query processing.

In this module, you will learn how to use `WITH` to:

* Initialize data for a `MATCH` clause.
* Define and name a subset of data for a query.
* Limit data that is processed.
* Pass data from one part of a query to the next part of the query (pipelining).
* Unwind a temporary list for processing in a later part of a query.

## Scoping Variables

You can define and initialize variables to be used in the query with a `WITH` clause.

```
WITH  'toy story' AS mt, 'Tom Hanks' AS actorName
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WITH m, toLower(m.title) AS movieTitle
WHERE p.name = actorName
AND movieTitle CONTAINS mt
RETURN m.title AS movies, movieTitle
```

Before the MATCH clause, we define a variable, actorName to have a value of Tom Hanks. The variable, 
actorName is in the scope of the query, so it can be used like a parameter. The query itself can be 
reused with a different value for actorName.
A WITH clause is used to define or redefine the scope of variables. Because we want to redefine what is used 
for the WHERE clause, we add a new `WITH` clause after `MATCH`. 
We must add the m to the second `WITH` clause so that the node can be used to return the title of the node. 
This creates a new scope for the remainder of the query so that m and movieTitle can be used to return values. 
If you were to remove the m in the second WITH clause, the query would not compile.


We can also use `WITH` to limit how many m nodes are used later in the query. Passing nodes on to the next 
`MATCH` clause is called pipelining that will be introduced in the next section.

```
WITH  'Tom Hanks' AS theActor
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = theActor
WITH m  LIMIT 2
// can run some more query logic here with another MATCH
RETURN m.title AS movies
```

If you are limiting the nodes to process further on in the query or for the RETURN clause, you can also order them:

```
WITH  'Tom Hanks' AS theActor
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = theActor
WITH m ORDER BY m.year LIMIT 5
// possibly do more with the five m nodes in a particular order
RETURN m.title AS movies, m.year AS yearReleased
```

## Pipeline Queries


A very common use of WITH is to aggregate data so that intermediate results can be used to create the final returned 
data or to pass the intermediate results to the next part of the query.

```
MATCH (:Movie {title: 'Toy Story'})-[:IN_GENRE]->(g:Genre)<-[:IN_GENRE]-(m)
WHERE m.imdbRating IS NOT NULL
WITH g.name AS genre,
count(m) AS moviesInCommon,
sum(m.imdbRating) AS total
RETURN genre, moviesInCommon,
total/moviesInCommon AS score
ORDER By score DESC
```

In this query we are counting the number of movies that share the same Genre node. We use count() to count the number of 
rows and sum() to total the imdbRating for each movie for the Genre. These values are calculated as part of the aggregation
and then used to return the data. In the WITH clause we pass on only the values we need to return a row for the Genre.

Here is another example that shows aggregation and pipelining:

```
MATCH (u:User {name: "Misty Williams"})-[r:RATED]->(:Movie)
WITH u, avg(r.rating) AS average
MATCH (u)-[r:RATED]->(m:Movie)
WHERE r.rating > average
RETURN average , m.title AS movie,
r.rating as rating
ORDER BY rating DESC
```
For this query, we first calculate the average rating for all movies that Misty Williams rated. Then we use this 
calculated value, average as a test for the second MATCH.

Another common use for the WITH clause is to collect results into a list that will be returned:
This query collects the names of actors who acted in the movies containing the string 'New York'. This aggregation 
collects the names and totals the number of actors.

```
MATCH (m:Movie)--(a:Actor)
WHERE m.title CONTAINS 'New York'
WITH m, collect (a.name) AS actors,
count(*) AS numActors
RETURN m.title AS movieTitle, actors
ORDER BY numActors DESC
```

Here is another example where we perform a 2-step aggregation for collecting a list of maps:
```
MATCH (m:Movie)<-[:ACTED_IN]-(a:Actor)
WHERE m.title CONTAINS 'New York'
WITH m, collect (a.name) AS actors,
count(*) AS numActors
ORDER BY numActors DESC
RETURN collect(m { .title, actors, numActors }) AS movies
```

A best practice is to execute queries that minimize the number of rows processed in the query. One way to do that 
is to limit early in the query. This also helps in reducing the number of properties loaded from the 
database too early.

```
PROFILE MATCH (p:Actor)
WHERE p.born.year = 1980
WITH p  LIMIT 3
MATCH (p)-[:ACTED_IN]->(m:Movie)
WITH p, collect(m.title) AS movies
RETURN p.name AS actor,  movies
```

Use DISTINCT when necessary  to ensure no duplication as follows.
For example, this collects the names of the genres for the movies that actor acted in - and removes duplicates.

```
MATCH (p:Actor)
WHERE p.born.year = 1980
WITH p  LIMIT 3
MATCH (p)-[:ACTED_IN]->(m:Movie)-[:IN_GENRE]->(g:Genre)
WITH p, collect(DISTINCT g.name) AS genres
RETURN p.name AS actor, genres
```

## Unwinding Lists

Sometimes it is useful to collect elements as intermediate results that are passed on to a later part of a query.
For example, the graph you are working with contains languages and countries lists for each Movie node. If you wanted
to refactor the graph to create a Language node and associate it with any Movie node that had that particular language
in its languages list, you could unwind the list to access each element in the list.

`UNWIND` returns a row for each element of a list.

```
MATCH (m:Movie)
UNWIND m.languages AS lang
WITH m, trim(lang) AS language
// this automatically, makes the language distinct because it's a grouping key
WITH language, collect(m.title) AS movies
RETURN language, movies[0..10]
```

This query:

* Retrieves all Movie nodes.
* For each Movie node, it unwinds the languages list to create a list called lang. Notice that we use the trim() 
function to ensure there are no extraneous whitespace characters in the language name.
* Then we use the element of the list to find all Movies that use that language.
* Finally, we return a row that contains each language name and the list of up to 10 movie titles for that language.