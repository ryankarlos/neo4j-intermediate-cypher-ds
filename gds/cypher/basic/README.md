# Basic Cypher Queries


**Testing Equality or greater or equal than**

Execute the query block below to

* Find all :Person nodes with the name, Tom Hanks.
* We then traverse the :ACTED_IN relationships to all :Movie nodes and filter for movies with a year property equal to 2013.
* Return the movie titles.

We are specifying the pattern to traverse through the graph, and then filtering on what data is retrieved within that pattern.
We then return the title property for the three movie titles that satisfy the query.

Your queries will execute faster if the graph has indexes on property values. This course does not cover creating indexes. 
You typically create indexes for property values that cover your application’s most important queries.

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Tom Hanks'
AND m.year = 2013
RETURN m.title
```


You can also test inequality of a property using the <> predicate.
This query returns the names of all actors that acted in the movie Captain Phillips where Tom Hanks is excluded. 
It returns the names of the three actors that satisfy the filtering criteria.


```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name <> 'Tom Hanks'
AND m.title = 'Captain Phillips'
RETURN p.name
```

You can test both numbers and strings for values less than (<) or greater than (>) a value. Adding the equals sign will
include the specified number within the predicate.

```
MATCH (m:Movie) WHERE m.title = 'Toy Story'
RETURN
    m.year < 1995 AS lessThan, //  Less than (false)
    m.year <= 1995 AS lessThanOrEqual, // Less than or equal(true)
    m.year > 1995 AS moreThan, // More than (false)
    m.year >= 1995 AS moreThanOrEqual // More than or equal (true)
```


**Testing Ranges**

To test for property values within a range, you can use a combination of less than and greater than.
Here we test a range of values. This query returns the four movies that Tom Hanks acted in between 2005 and 2010, inclusive.

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Tom Hanks'
AND  2005 <= m.year <= 2010
RETURN m.title, m.released
```

We can also use OR to expand the filtering to return more data as follows:

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Tom Hanks'
OR m.title = 'Captain Phillips'
RETURN p.name, m.title
```

This query returns rows containing the name and title. Each row represents an actor who acted in Captain Phillips or 
has the name of Tom Hanks. In this result you will see multiple rows for Tom Hanks and each movie he acted in. 
You will also see multiple rows for each of the actors who acted in the movie, Captain Phillips.

**Testing null property values**

A property for a node or relationship is null if it does not exist. You can test the existence of a property for a 
node using the IS NOT NULL predicate.

```
MATCH (p:Person)
WHERE p.died IS NOT NULL
AND p.born.year >= 1985
RETURN p.name, p.born, p.died
```

This query returns the names, born, and died properties for all people who have a value for their died property and who
were born after 1985. In this graph, it returns 6 rows.

And we can test if a property exists using the IS NULL predicate:

```
MATCH (p:Person)
WHERE p.died IS NULL
AND p.born.year <= 1922
RETURN p.name, p.born, p.died
```

This query returns all people born before 1923 who do not have a died property value. It returns 21 rows for our dataset.

**Testing labels or patterns?**

Depending on your data model, it may be useful to test that a node has a label. This is particularly
useful when a node may have multiple labels.
You can test for a label’s existence on a node using the {alias}:{label} syntax.

```
MATCH (p:Person)
WHERE  p.born.year > 1960
AND p:Actor
AND p:Director
RETURN p.name, p.born, labels(p)
```

This query will retrieve all Person nodes with the label Actor and Director that were born after 1960. The `labels() `
function returns the list of labels for a node. It returns 163 rows.

Here is a variation of the previous query. Rather than using the Actor or Director labels, it uses the relationship 
types :ACTED_IN and :DIRECTED to imply that the node at the other end of the relationship has the correct label:

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)<-[:DIRECTED]-(p)
WHERE  p.born.year > 1960
RETURN p.name, p.born, labels(p), m.title
```

This query retrieves all people born after 1960 (assigned to the alias p), who also acted in a movie and directed the 
same movie. This query is more specific in that the same person both directed and acted in the movie. In the previous
query, we were only looking at labels and not relationships to movies. This query returns 134 rows, but notice that 
some people directed and acted in multiple movies, for example, Jodie Foster.

**Discovering relationship types**

A query with a pattern need not specify the relationship type in the query:

```
MATCH (p:Person)-[r]->(m:Movie)
WHERE  p.name = 'Tom Hanks'
RETURN m.title AS movie, type(r) AS relationshipType
```

This query retrieves all Movie nodes that are related to Tom Hanks. Each row returned is a movie title and the type 
of relationship that Tom Hanks has to that movie. We use the type() function to return the type of the relationship, r. 
Notice that for this query, Tom Hanks has both an ACTED_IN and DIRECTED relationship to the movie, Larry Crowne.

**Testing list inclusion**

You can test if a value is in a list property. This query returns the titles, languages, countries of all movies 
that have Israel in their list of countries.

```
MATCH (m:Movie)
WHERE "Israel" IN m.countries
RETURN m.title, m.languages, m.countries
```

## Profiling 

A pattern is a combination of nodes and relationships that is used to traverse the graph at runtime. You can write 
queries that test whether a pattern exists in the graph.
You can use the PROFILE keyword to show the total number of rows retrieved from the graph in the query.

```
PROFILE MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Clint Eastwood'
AND exists {(p)-[:DIRECTED]->(m)}
RETURN m.title
```

In the profile, you can see that the initial row is retrieved, but then rows are retrieved for each Movie 
that Clint Eastwood acted in. Then the test is done for the :DIRECTED relationship.
However, there is a better/more efficient way to do the same query as above

```
PROFILE MATCH (p:Person)-[:ACTED_IN]->(m:Movie)<-[:DIRECTED]-(p)
WHERE  p.name = 'Clint Eastwood'
RETURN m.title
```

The query retrieves the anchor (the Clint Eastwood Person node). It then finds a Movie node where Clint Eastwood is related to with
the ACTED_IN relationship. It then traverses all DIRECTED relationships that point to the same Clint Eastwood node.
This traversal is very efficient because the graph engine can take the internal relationship cardinalities into account.
Notice, however that this query is much more efficient. It retrieves much less data than the first query. 

Note that the performance of queries that use patterns will depend upon the data model for your graph and also the number of 
nodes in the traversal.

In cases where you want to exclude relationships .e.g `DIRECTED`, then the only way to do this is as below - which may
not be non performant.

```
PROFILE MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Clint Eastwood'
AND NOT exists {(p)-[:DIRECTED]->(m)}
RETURN m.title
```


### EXPLAIN vs PROFILE keywords 
The difference between using EXPLAIN and PROFILE is that EXPLAIN provides estimates of the query steps where PROFILE provides 
the exact steps and number of rows retrieved for the query. Providing you are simply querying the graph and not updating anything, 
it is fine to execute the query multiple times using PROFILE. In fact, as part of query tuning, you should execute the 
query at least twice as the first execution involves the generation of the execution plan which is then cached. That is, 
the first PROFILE of a query will always be more expensive than subsequent queries.

## Multiple and Optional Match 

We can use multiple match clauses as below

```
MATCH (a:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.year > 2000
MATCH (m)<-[:DIRECTED]-(d:Person)
RETURN a.name, m.title, d.name
```

This query retrieves the anchor nodes (movies released after the year 2000) and the set of actors for each movie.
It then follows the :DIRECTED relationships to each Movie node to retrieve the director of each movie.
It returns the triple of actor name, movie title, director name.

An alternative to using multiple MATCH clauses is to specify multiple patterns:

```
MATCH (a:Person)-[:ACTED_IN]->(m:Movie),
      (m)<-[:DIRECTED]-(d:Person)
WHERE m.year > 2000
RETURN a.name, m.title, d.name
```

In this query, multiple patterns are specified. In the second pattern, the variable m is used from the first pattern.
In general, using a single MATCH clause will perform better than multiple MATCH clauses. This is because 
relationship uniqueness is enforced so there are fewer relationships traversed.

In most cases, specifying a single pattern will yield the best performance as below:

```
MATCH (a:Person)-[:ACTED_IN]->(m:Movie)<-[:DIRECTED]-(d:Person)
WHERE m.year > 2000
RETURN a.name, m.title, d.name```
```

OPTIONAL MATCH matches patterns with your graph, just like MATCH does. The difference is that if no matches are found, 
OPTIONAL MATCH will use nulls for missing parts of the pattern. OPTIONAL MATCH could be considered the 
Cypher equivalent of the outer join in SQL.

```
MATCH (m:Movie) WHERE m.title = "Kiss Me Deadly"
MATCH (m)-[:IN_GENRE]->(g:Genre)<-[:IN_GENRE]-(rec:Movie)
OPTIONAL MATCH (m)<-[:ACTED_IN]-(a:Actor)-[:ACTED_IN]->(rec)
RETURN rec.title, a.name
```

This query returns rows where the pattern where an actor acted in both movies is optional and a null value is returned 
for any row that has no value. In general, and depending on your graph, an optional match will return more rows.

## Map Projections

Many applications that access Neo4j via their drivers use Cypher to retrieve data from the graph as objects that will 
be used by the application. In Neo4j Browser, when nodes are returned, you can either view them as a graph, or you can 
view them in table view where all properties for a node are a single row. The data is returned as rows of data where 
each row represents a JSON-style object for a node.
. If you view the data returned as a table, it returns internal node information such as labels and identity, 
along with the property values.


you can return data is without the internal node information, that is, only property values.
The query below returns an object named person that contains all of the property values for the node. 
It does not contain any of the internal information for the node such as its labels or id.

```
MATCH (p:Person)
WHERE p.name CONTAINS "Thomas"
RETURN p { .* } AS person
ORDER BY p.name ASC
```
Additionally, you can customize what properties you return in the objects.
Here the person objects returned will include the name and born properties.

```
MATCH (p:Person)
WHERE p.name CONTAINS "Thomas"
RETURN p { .name, .born } AS person
ORDER BY p.name
```

Here is an example, where we are adding information to the objects returned that are not part of the data in the graph.
In addition to returning all property values for each Woody Allen movie, we are returning a property of favorite with 
a value of true for each Movie object returned.

```
MATCH (m:Movie)<-[:DIRECTED]-(d:Director)
WHERE d.name = 'Woody Allen'
RETURN m {.*, favorite: true} AS movie
```

## Conditionally Return Data 


Cypher has a CASE clause that you can specify to compute the data returned which may be different from what is in the graph.
In thie query below we can transform the data returned to reflect the timeframe for the movie.

```
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE p.name = 'Henry Fonda'
RETURN m.title AS movie,
CASE
WHEN m.year < 1940 THEN 'oldies'
WHEN 1940 <= m.year < 1950 THEN 'forties'
WHEN 1950 <= m.year < 1960 THEN 'fifties'
WHEN 1960 <= m.year < 1970 THEN 'sixties'
WHEN 1970 <= m.year < 1980 THEN 'seventies'
WHEN 1980 <= m.year < 1990 THEN 'eighties'
WHEN 1990 <= m.year < 2000 THEN 'nineties'
ELSE  'two-thousands'
END
AS timeFrame
```