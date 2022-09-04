## Graph Catalog 

The graph catalog is a concept that allows you to manage graph projections in GDS. This includes

* creating (a.k.a projecting) graphs
* viewing details about graphs
* dropping graph projections
* exporting graph projections
* writing graph projection properties back to the database



In the recommendations graph, we can create a projection from the Actor and Movie nodes and the ACTED_IN relationship 
with the below command.

```
CALL gds.graph.project('my-graph-projection', ['Actor','Movie'], 'ACTED_IN')
```

to list the graph projections that currently exist in db, we can run the following: 

```
CALL gds.graph.list() YIELD graphName, nodeCount, relationshipCount, schema
```

### Streaming and Writing Node Properties

There will be times when we want to take the results from our algorithm calculations and either stream them into 
another process or write them back to the database. The graph catalog has methods to stream and write both 
node properties and relationship properties for these purposes. 

for example, we can stream the top 10 most prolific actors by movie count using the `streamNodeProperty` graph 
catalog operation.


```
CALL gds.graph.streamNodeProperty('my-graph-projection','numberOfMoviesActedIn')
YIELD nodeId, propertyValue
RETURN gds.util.asNode(nodeId).name AS actorName, propertyValue AS numberOfMoviesActedIn
ORDER BY numberOfMoviesActedIn DESCENDING, actorName LIMIT 10
```

Or to write back to database

```
CALL gds.graph.writeNodeProperties('my-graph-projection',['numberOfMoviesActedIn'], ['Actor'])
```

### Exporting Graphs

In a data science workflow, you may encounter situations where you need to bulk export data from a graph projection 
after performing graph algorithms and other analytics. For example, you may want to:

* export graph features for training a machine learning model in another environment
* create separate analytical views for downstream analytics and/or sharing with colleagues.
* produce snapshots of analytical results and persist to the filesystem

The graph catalog has two methods for export:

**gds.graph.export** to export a graph into a new database - effectively copying the projection into a 
separate Neo4j database

**gds.beta.graph.export.csv** to export a graph to csv files

### Dropping Graphs

Projected graphs take up space in memory so once we are done working with a graph projection it is smart to
remove it. We can do this with the drop command below:]

```
CALL gds.graph.drop('my-graph-projection')
```

Now when we list graphs it will be empty again.

```
CALL gds.graph.drop('my-graph-projection')
```