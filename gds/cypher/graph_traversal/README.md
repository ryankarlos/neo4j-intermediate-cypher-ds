When the execution plan is created, it determines the set of nodes that will be the starting points for the query. 
The anchor for a query is often based upon a MATCH clause. The anchor is typically determined by meta-data that 
s stored in the graph or a filter that is provided inline or in a WHERE clause. The anchor for a query will be 
based upon the fewest number of nodes that need to be retrieved into memory.

Next, we will look at some examples of how queries are anchored based upon the hueristics used by the graph engine.

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Eminem'
RETURN  m.title AS movies
```

When the query above is executed:

* The Eminem Person node is retrieved.
* Then the first ACTED_IN relationship is traversed to retrieve the Movie node for 8 Mile.
* Then the second ACTED_IN relationship is traversed to retrieve the Movie node for Hip Hop Witch, Da.
* The title property is retrieved so that the results can be returned.

if we add another query to include multiple patterns

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie),
(coActors:Person)-[:ACTED_IN]->(m)
WHERE p.name = 'Eminem'
RETURN m.title AS movie ,collect(coActors.name) AS coActors
```

When the query executes: 

1. For the first pattern in the query, the Eminem Person node is retrieved.
2. Then the first ACTED_IN relationship is traversed to retrieve the Movie node for 8 Mile.
3. The second pattern in the query is then used.
4. Each ACTED_IN relationship to the same 8 Mile movie is traversed to retrieve three co-actors.
5. If the ACTED_IN relationship has been traversed already, it is not traversed again.
6. Then the second ACTED_IN relationship is traversed to retrieve the Movie node for Hip Hop Witch, Da.
7. Each ACTED_IN relationship to the same Hip Hop Witch, Da movie is traversed to retrieve three co-actors.
8. The title property for the Movie node is retrieved so that the results can be returned.
9. Notice that for this query, a depth-first traversal occurs.

With multiple match clauses 

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Eminem'
MATCH (allActors:Person)-[:ACTED_IN]->(m)
RETURN m.title AS movie, collect(allActors.name) AS allActors

```

When the query executes

1. For the first MATCH clause in the query, the Eminem Person node is retrieved.
2. Then the first ACTED_IN relationship is traversed to retrieve the Movie node for 8 Mile.
3. The second MATCH clause in the query is then executed.
4. Each ACTED_IN relationship to the same 8 Mile movie is traversed to retrieve all actors, including the relationship 
5. to the Eminem node.
6. Then the query returns back to the first MATCH clause to traverse the ACTED_IN relationship to the Hip Hop Witch, Da movie.
7. The second MATCH clause in the query is then executed.
8. Each ACTED_IN relationship to the same Hip Hop Witch, Da movie is traversed to retrieve all actors.
9. Notice that for this query, a depth-first traversal occurs just as it did for the previous query. The one difference 
10. in the outcome, however is that the Eminem node is added as a result of the second MATCH.


## Avoid Labels for better performance


Another graph optimization that you can take advantage of is to reduce labels used in your query patterns. 
Having a label for the anchor nodes in a pattern is good:

```
PROFILE MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Tom Hanks'
RETURN m.title AS movie
```

The Person label for the anchor node retrieval is good here, but the label for the other side of the pattern is
unnecessary. Having the label on the non-anchor node forces a label check, which is really not necessary.

Here is a more performant way to do this query. With this second query, you see that there are fewer db hits.

```
PROFILE MATCH (p:Person)-[:ACTED_IN]->(m)
WHERE p.name = 'Tom Hanks'
RETURN m.title AS movie
```

### Returning paths

You can return paths in your query as follows:

```
MATCH p = ((person:Person)-[]->(movie))
WHERE person.name = 'Walt Disney'
RETURN p
```

This query returns 5 paths. If you view the objects (table view in Neo4j Browser), you will see that each 
row returned represents the Person node, the Movie node, and the relationship.

In some applications, it may be useful to work with path objects. Cypher has some useful functions that 
can be used to analyze paths:

* length(p) returns the length of a path.
* nodes(p) returns a list containing the nodes for a path.
* relationships(p) returns a list containing the relationships for a path.

## Varying Length Traversal and shorrtest path


Any graph that represents social networking, hierarchies, transport, flow, or dependency networks will most likely have
multiple paths of varying lengths. Think of the connected relationship in LinkedIn and how connections are made 
by people connected to more people.

Here are two use cases for this type of traversal:

* Finding the shortest path between two nodes.
* Finding out how "close" nodes are to each other in the graph.
* 
In Neo4j uniqueness of relationships is always adhered to. That is, there will never be two relationships of the same 
* type and direction between two nodes. This enables Neo4j to avoid cycles or infinite loops in graph traversal.


### Shortest Path

Cypher has a built-in function that returns the shortest path between any two nodes, if one exists.
For shortestPath() and allShortestPaths() you can provide an upper bound on the length of the path(s), but not a lower bound.

### Varying Length traversal

Suppose you want to retrieve all Person nodes that are exactly four hops away from Eminem using the ACTED_IN relationship.

```
MATCH (p:Person {name: 'Eminem'})-[:ACTED_IN*4]-(others:Person)
RETURN  others.name
```

This is what happens when the equery executes


The Eminem Person node is retrieved.
Then the ACTED_IN relationships are traversed through the Movie node where Brittany Murphy for 8 Mile is retrieved and 
Little Black Book to return the two Person nodes. Then the four ACTED_IN relationships are traversed through 
the Movie node for 8 Mile and The Prophecy II to return the two Person nodes. Only Person nodes that are exactly 
4 hops from Eminem are returned. Suppose you want to retrieve all Person nodes that are up to four 
hops away from Eminem using the ACTED_IN relationship.

```
MATCH (p:Person {name: 'Eminem'})-[:ACTED_IN*1..4]-(others:Person)
RETURN  others.name
```
When the query executes, first the Eminem Person node is retrieved. Then the ACTED_IN relationships are 
traversed through the Movie node for 8 Mile and for the Little Black Book. During this traversal we retrieve the Person 
node two hops away and the two Person nodes that are four hops away. Then the ACTED_IN relationships 
are traversed through the Movie node for 8 Mile and for The Prophecy II.
We have already retrieved Brittany Murphy who is four hops away, but we add two more Person nodes.
This depth-first traversal and retrieval continues until all Person nodes that are two hops away 
and four hops away are retrieved.