## Projections

There are 2 primary types of projections in GDS, native projections and cypher 
projections. In summary, native projections are optimized for efficiency and 
performance to support graph data science at scale. Cypher projections are 
optimized for flexibility and customization to support exploratory analysis, 
experimentation, and smaller graph projections.

While the native projection is scalable and fast, its filtering and aggregation 
capabilities aren’t as flexible as Cypher. The Cypher projection, as 
its name implies, uses Cypher to define the projection pattern, and as 
such, enables more flexibility.

We will go over each of the ptojection types in the next sections.

### Native Projections 

Native projections provide the best performance by reading from the Neo4j store files directly.
It is recommended for both development and production phases.

In addition to just projecting node and relationship elements as-is from the database,
native projections offer a variety of other features. Below are a few of the big ones:

* the inclusion of numeric node and relationship properties
* altering relationship direction or "orientation"
* aggregating parallel relationships

These options help prepare the projection for different types of analytical workflows and algorithms.
There are multiple different options for the nodeProjection and relationshipProjection.


Let’s first consider the very basic scenario where we want to project nodes and relationships 
as-is without any properties. You can use a list-like syntax for both the node labels and 
relationships you want to include. Take the below example where we project the User and 
Movie nodes with the RATED relationship. This type of projection is very common for graph 
data science based Recommendation Systems as it supports variations of Implicit Collaborative 
Filtering - a memory based approach to recommendation.

```
CALL gds.graph.project('native-proj',['User', 'Movie'], ['RATED']);
```
There are various forms of shorthand syntax too. For example, if you plan to include only one 
node label or relationship type you can just use a single string value. We could for example
just enter the value RATED for the relationshipProjection and get an equivalent projection.

```
CALL gds.graph.project('native-proj',['User', 'Movie'], 'RATED');
```

The wildcard character '*' can be used to include all nodes and/or relationships in the database. 
The below projections all nodes and relationships.

```
CALL gds.graph.project('native-proj','*', '*');
```

#### Changing Relationship Orientation

Some graph algorithms are designed to work on undirected relationships. Other algorithms are 
directed, but we may need to reverse the direction of the relationship 
in the database to get the analytic we want.

there are three orientation options we can apply to relationship types in the relationshipProjection:

NATURAL: same direction as in the database (default)
REVERSE: opposite direction as in the database
UNDIRECTED: undirected


#### Parallel Relationship Aggregations

The Neo4j database allows you to store multiple relationships of the same type and 
direction between two nodes. These are colloquially known as parallel relationships. 
For example, consider a graph of financial transaction data where users send money 
to one another. If a user sends money to the same user multiple times this can 
form multiple parallel relationships.

Sometimes you will want to aggregate these parallel relationships into a single relationship
in preparation for running graph algorithms or machine learning. This is because graph 
algorithms may count each relationship between two nodes separately when all we need to 
consider is whether a single relationship exists between them. Other times we may want 
to weight the connection between two nodes higher if more parallel relationships exists, 
but it’s not always easy to do so without aggregating the relationships first depending 
on which algorithm you use.


Native projections allow for this aggregation. When you conduct relationship aggregation 
you can generate aggregate statics too, such as parallel relationship counts or sums or 
averages of relationship properties which can then be used as weights. Below is an example 
of aggregating relationships without any properties


```

CALL gds.graph.project(
  'user-proj',
  ['User'],
  {
    SENT_MONEY_TO: { aggregation: 'SINGLE' }
  }
);
```

We can create a property with the count of the relationships as well.
This will create a new relationship property `numberofTransactions` with the count of number 
of relationships between the two nodes


```
CALL gds.graph.project(
  'user-proj',
  ['User'],
  {
    SENT_MONEY_TO: {
      properties: {
        numberOfTransactions: {
          // the wildcard '*' is a placeholder, signaling that
          // the value of the relationship property is derived
          // and not based on Neo4j property.
          property: '*',
          aggregation: 'COUNT'
        }
      }
    }
  }
);

```


We can also take the sum, min or max of relationship properties during aggregation. Suppose the 
value of money sent in separate transactions was 100, 120, 80 then we 
will have a new relationship property `totalAmount` with the value 300

```
CALL gds.graph.project(
  'user-proj',
  ['User'],
  {
    SENT_MONEY_TO: {
      properties: {
        totalAmount: {
          property: 'amount',
          aggregation: 'SUM'
        }
      }
    }
  }
);

```

#### Including Node and Relationship Properties 


Node and relationship properties may be useful to consider in graph analytics.
They can be used as weights in graph algorithms and features for machine learning.

Below is an example of including multiple movie node properties and the rating 
relationship property.

```
CALL gds.graph.drop('native-proj', false);

CALL gds.graph.project(
    'native-proj',
    ['User', 'Movie'],
    {RATED: {orientation: 'UNDIRECTED'}},
    {
        nodeProperties:{
            revenue: {defaultValue: 0},
            budget: {defaultValue: 0},
            runtime: {defaultValue: 0}
        },
        relationshipProperties: ['rating'] 
    }
);
```

The defaultValue parameter allows us to fill in missing values with a default. 
In this case we use 0.


To drop a graoh projection, use the syntax below. This will need to be done before 
you attempt to create a new graph projection with a name that already exists (otherwise there will
be an error)

```
CALL gds.graph.drop('native-proj');
```

## Cypher Projections

Cypher projections are intended to be used in exploratory analysis and developmental phases where additional 
flexibility and/or customization is needed. They can also work in production settings 
where you plan to subset only a small portion of the graph, such as a relatively small 
community or neighborhood of nodes.
While Cypher projections offer more flexibility and customization, they have a diminished focus
on performance relative to native projections and as a result won’t perform as quickly 
or as well on larger graphs. 

A Cypher projection takes three mandatory arguments: graphName, nodeQuery, and relationshipQuery. In 
addition, the optional configuration parameter allows us to further configure graph creation.

The two of the most common cases for using Cypher Projections are:

* **Complex Filtering**: Using node and/or relationship property conditions or other more complex MATCH/WHERE 
  conditions to filter the graph, rather than just node label and relationship types.
* **Aggregating Multi-Hop Paths with Weights**: The relationship projection required aggregating the 
  (Actor)-[ACTED_IN]-(Movie)-[ACTED_IN]-(Actor) pattern to a (Actor)-[ACTED_WITH {actedWithCount}]-(Actor) 
  pattern where the actedWithCount is a relationship weight property. This type of projection, where we need to
  transform multi-hop paths into an aggregated relationship that connects the source and target node, is a 
  commonly occurring pattern in graph analytics.

There are a few other special use cases for Cypher projections too, including merging different node labels and
relationship types and defining virtual relationships between nodes based on property conditions or other query logic.


### Example

Suppose we wanted to know which actors are the most influential in terms of the number of other actors they have 
been in recent, high grossing, movies with.

For the sake of this example, we will call a movie “recent” if it was released on or after 1990, and 
high-grossing if it had revenue >= $1M.

The graph is not set up to answer this question well with a direct native projection. However, we can use a 
cypher projection to filter to the appropriate nodes and perform an aggregation to create an ACTED_WITH relationship
that has a actedWithCount property going directly between actor nodes.

```
CALL gds.graph.project.cypher(
  'proj-cypher',
  'MATCH (a:Actor) RETURN id(a) AS id, labels(a) AS labels',
  'MATCH (a1:Actor)-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(a2)
   WHERE m.year >= 1990 AND m.revenue >= 1000000
   RETURN id(a1) AS source , id(a2) AS target, count(*) AS actedWithCount, "ACTED_WITH" AS type'
);
```

Once that is done we can apply degree centrality like we did last lesson. Except we will weight the degree
centrality by actedWithCount property and also directly stream the top 10 results back. This counts how many
times the actor has acted with other actors in recent, high grossing movies.

```
CALL gds.degree.stream('proj-cypher',{relationshipWeightProperty: 'actedWithCount'})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC LIMIT 10
```
