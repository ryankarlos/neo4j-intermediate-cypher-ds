# Basic Cypher Queries

Cypher is a query language designed for graphs. It works by matching patterns in the data. We retrieve data from 
the graph using the MATCH keyword. You can think of the MATCH clause as similar to the FROM clause in an SQL statement.

For example, if we want to find a Person in the graph, we would MATCH a pattern of a single node with a label of :Person - 
prefixed with a colon :.
Suppose we want to retrieve all Person nodes from the graph. We can assign a variable by placing a value before the colon. 
Let’s use the variable p. Now that p represents all Person nodes retrieved from the graph, we can return them 
using the RETURN clause.

```
MATCH (p:Person)
RETURN p
```

This query returns all nodes in the graph with the Person label. You can view the results returned using the graph view 
or the table view. When you select the table view, you can also see the properties for the nodes returned.


Now, say we want to find the node which represents the Person who’s name is Tom Hanks. Our Person nodes all have a name
property. We can use the braces {..} to specify the key/value pair of name and Tom Hanks as the filter. As Tom Hanks is
a string, we will need to place it inside single or double quotes.

```
MATCH (p:Person {name: 'Tom Hanks'})
RETURN p
```

In our Cypher statement, we can access properties using a dot notation. For example, to return the name 
property value using its property key p.name.

```
MATCH (p:Person {name: 'Tom Hanks'})
RETURN p.born
```

Another way that you can filter queries is by using the WHERE clause, rather than specifying 
the property value inline with braces.

```
MATCH (p:Person)
WHERE p.name = 'Tom Hanks' OR p.name = 'Rita Wilson'
RETURN p.name, p.born
```

## Testing Equality or greater or equal than

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


## Testing Ranges

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

## Testing null property values

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

## Testing labels or patterns?

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

## Discovering relationship types

A query with a pattern need not specify the relationship type in the query:

```
MATCH (p:Person)-[r]->(m:Movie)
WHERE  p.name = 'Tom Hanks'
RETURN m.title AS movie, type(r) AS relationshipType
```

This query retrieves all Movie nodes that are related to Tom Hanks. Each row returned is a movie title and the type 
of relationship that Tom Hanks has to that movie. We use the type() function to return the type of the relationship, r. 
Notice that for this query, Tom Hanks has both an ACTED_IN and DIRECTED relationship to the movie, Larry Crowne.

## Testing list inclusion

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

## Writing Data to Neo4j


We use the MERGE keyword to create a pattern in the database. After the MERGE keyword, we specify the pattern that we
want to create. Usually this will be a single node or a relationship between two nodes.
When using MERGE to create a node, we must specify the label for the node and the name and value for the 
property that will be the primary key for the node.

Suppose we want to create a node to represent Michael Cain. Run this Cypher code to create the node.

```
MERGE (p:Person {name: 'Michael Cain'})
```

Verify that the node was created.

```
MATCH (p:Person {name: 'Michael Cain'})
RETURN p
```

We can also chain multiple MERGE clauses together within a single Cypher code block.
This code creates two nodes, each with a primary key property. Because we have specified the variables p and m, 
we can use them in the code to return the created nodes.

```
MERGE (p:Person {name: 'Katie Holmes'})
MERGE (m:Movie {title: 'The Dark Knight'})
RETURN p, m
```

**Note** Cypher has a CREATE clause you can use for creating nodes. The benefit of using CREATE is that it does not look up 
the primary key before adding the node. You can use CREATE if you are sure your data is clean and you want greater 
speed during import. We use MERGE in this training because it eliminates duplication of nodes.

you can use MERGE to create relationships between two nodes. First you must have references to the two nodes you 
will be creating the relationship for. When you create a relationship between two nodes, it must have type and direction.

For example, if the Person and Movie nodes both already exist, we can find them using a MATCH clause before creating 
the relationship between them.

```
MATCH (p:Person {name: 'Michael Cain'})
MATCH (m:Movie {title: 'The Dark Knight'})
MERGE (p)-[:ACTED_IN]->(m)
```

Here we find the two nodes that we want to create the relationship between. Then we use the reference to the 
found nodes to create the ACTED_IN relationship.

We can confirm that this relationship exists as follows:

```
MATCH (p:Person {name: 'Michael Cain'})-[:ACTED_IN]-(m:Movie {title: 'The Dark Knight'})
RETURN p, m
```

We can also chain multiple MERGE clauses together within a single Cypher code block.
If we did not specify the direction of the relationship, it will always be assumed left-to-right.

```
MERGE (p:Person {name: 'Chadwick Boseman'})
MERGE (m:Movie {title: 'Black Panther'})
MERGE (p)-[:ACTED_IN]-(m)
```
What MERGE does is create the node or relationship if it does not exist in the graph.
You can execute this Cypher code multiple times and it will not create any new nodes or relationships.

Another way your can create these nodes and relationship is as follows:

```
MERGE (p:Person {name: 'Chadwick Boseman'})-[:ACTED_IN]->(m:Movie {title: 'Black Panther'})
RETURN p, m
```


### Adding or updating relationship properties


There are two ways that you can set a property for a node or relationship.

1. Inline as part of the MERGE clause. for example

```
MERGE (p:Person {name: 'Michael Cain'})
MERGE (m:Movie {title: 'Batman Begins'})
MERGE (p)-[:ACTED_IN {roles: ['Alfred Penny']}]->(m)
RETURN p,m
```

2. Using the SET keyword for a reference to a node or relationship. We can set single or multiple properties

```
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
SET r.roles = ['Alfred Penny'], r.year = 2008
RETURN p, r, m
```

If you have a reference to a node or relationship, you can also use SET to modify the property.
You can remove or delete a property from a node or relationship by using the REMOVE keyword e.g. `REMOVE p.born`, or 
setting the property to null `SET p.born = null`


### Merge Processing


You can also specify behavior at runtime that enables you to set properties when the node is created or when the node is found.
We can use the ON CREATE SET or ON MATCH SET conditions, or the SET keywords to set any additional properties.
If you want to set multiple properties for an ON CREATE SET or ON MATCH SET clause, you separate them by commas.

In this example, if the Person node for McKenna Grace does not exist, it is created and the createdAt property is set. 
If the node is found, then the updatedAt property is set. In both cases, the born property is set.

```
// Find or create a person with this name
MERGE (p:Person {name: 'McKenna Grace'})

// Only set the `createdAt` property if the node is created during this query
ON CREATE SET p.createdAt = datetime()

// Only set the `updatedAt` property if the node was created previously
ON MATCH SET p.updatedAt = datetime()

// Set the `born` property regardless
SET p.born = 2006

RETURN p
```

### Deleting Data

To delete any data in the database, you must first retrieve it, then you can delete it.
You can delete nodes, relationships, properties and labels.

You delete this node as follows where you first retrieve the node. Then with a reference to the node you can delete it.

```
MATCH (p:Person)
WHERE p.name = 'Jane Doe'
DELETE p
```

Neo4j provides a feature where you cannot delete a node if it has incoming or outgoing relationships. 
This prevents the graph from having orphaned relationships.
The DETACH keyword  deletes the relationship and the Person node.

```
MATCH (p:Person {name: 'Jane Doe'})
DETACH DELETE p
```

You can also delete all nodes and relationships in a database with this code.

```
MATCH (n)
DETACH DELETE n
```

Suppose we have added a label `Developer` to the node  `Person`

```
MATCH (p:Person {name: 'Jane Doe'})
SET p:Developer
RETURN p
```

To remove the newly-added label, you use the REMOVE clause. 
The node has two labels, Person and Developer. You can use a MATCH to find that node. 
Once we have a reference to that node, we can remove the label with the REMOVE clause.

```
MATCH (p:Person {name: 'Jane Doe'})
REMOVE p:Developer
RETURN p
```

To check what labels exist in a graph, we can run `CALL db.labels()`