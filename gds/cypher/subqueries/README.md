When you execute a series of MATCH clauses, all nodes and relationships retrieved are in memory. If the memory 
requirements for a set of MATCH clauses exceed the VM configured, the query will fail.

A subquery is a set of Cypher statements that execute within their own scope. A subquery is typically called from 
an outer enclosing query. Using a subquery, you can limit the number of rows that need to be processed.

Here are some important things to know about a subquery:

* A subquery returns values referred to by the variables in the RETURN clause.
* A subquery cannot return variables with the same name used in the enclosing query.

You must explicitly pass in variables from the enclosing query to a subquery.



In a CALL clause, you specify a query that can return data from the graph or derived from the graph. 
A set of nodes returned in the CALL clause can be used by the enclosing query.
The subquery is demarcated by the {}s here
```
CALL {
   MATCH (m:Movie) WHERE m.year = 2000
   RETURN m ORDER BY m.imdbRating DESC LIMIT 10
}
MATCH  (:User)-[r:RATED]->(m)
RETURN m.title, avg(r.rating)
```

Here is an example where the subquery is executed after the initial query and the enclosing query passes a variable, m into the subquery.

```
MATCH (m:Movie)
CALL {
    WITH m
    MATCH (m)<-[r:RATED]-(u:User)
     WHERE r.rating = 5
    RETURN count(u) AS numReviews
}
RETURN m.title, numReviews
ORDER BY numReviews DESC
```

In this query:

The first MATCH returns a row for every movie, m in the graph. It passes the Movie node,m to the subquery.
Then within the subquery, the query executes to find all users who gave that movie a rating of 5 and counts them.
The subquery returns the count. Back in the enclosing query, the title is returned, and the count of the number of rows returned from the subquery.
Using subqueries enables you to reduce the number of rows processed in a query.

As your queries become more complex, you may need to combine the results of multiple queries. You can do so with
UNION. With UNION, the queries you are combining must return the same number of properties or data

```
MATCH (m:Movie) WHERE m.year = 2000
RETURN {type:"movies", theMovies: collect(m.title)} AS data
UNION ALL
MATCH (a:Actor) WHERE a.born.year > 2000
RETURN { type:"actors", theActors: collect(DISTINCT a.name)} AS data
```

The first query returns an object with a type property of "movies" and a theMovies property that is a list of movies. 
It returns this object as a variable named Data
The second query returns an object with a type property of "actors" and a theActors property that is a list of actor 
names. It returns this object as a variable named Data
Because both queries return a variable named Data, we can combine the results using UNION ALL.

**Note** UNION ALL returns all results which is more efficient on memory but can lead to duplicates. UNION returns distinct results.

Results of a UNION cannot be directly post-processed. But if you wrap a UNION in a subquery, you can then further process the results.

Here is an example that uses UNION within a subquery:

```
MATCH (p:Person)
WITH p LIMIT 100
CALL {
  WITH p
  OPTIONAL MATCH (p)-[:ACTED_IN]->(m:Movie)
  RETURN m.title + ": " + "Actor" AS work
UNION
  WITH p
  OPTIONAL MATCH (p)-[:DIRECTED]->(m:Movie)
  RETURN m.title+ ": " +  "Director" AS work
}
RETURN p.name, collect(work)
```

This query:

* 100 Person nodes are retrieved and passed to the subquery.
* If that Person acted in the movie, its title with the Actor suffix is returned.
* The second part of the subquery does the same for the DIRECTED relationships.
* The work results are combined and collected.
* The result is the name of the person and their Actor or Director titles.