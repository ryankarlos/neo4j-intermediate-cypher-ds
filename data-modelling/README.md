# Graph Data Modelling

If you will use a Neo4j graph to support part or all of your application, you must collaboratively work with 
your stakeholders to design a graph that will answer the key use cases for the application and provide the best 
Cypher statement performance for the key use cases.

The Neo4j components that are used to define the graph data model are Nodes, Labels, Relationships and Properties.
In the next section, we will discuss the data modelling process.

## Data modeling process

Here are the steps to create a graph data model:

* Understand the domain and define specific use cases (questions) for the application.
* Develop the initial graph data model:
    a. Model the nodes (entities).
    b. Model the relationships between nodes.
* Test the use cases against the initial data model.
* Create the graph (instance model) with test data using Cypher.
* Test the use cases, including performance against the graph.
* Refactor (improve) the graph data model due to a change in the key use cases or for performance reasons.
* Implement the refactoring on the graph and retest using Cypher.

Graph data modeling is an iterative process. Your initial graph data model is a starting point, but as you learn more about 
the use cases or if the use cases change, the initial graph data model will need to change. In addition, you may find that 
especially when the graph scales, you will need to modify the graph (refactor) to achieve the best performance for your 
key use cases.

Refactoring is very common in the development process. A Neo4j graph has an optional schema which is quite flexible, 
unlike the schema in an RDBMS. A Cypher developer can easily modify the graph to represent an improved data model.

## Modelling Nodes 


Entities are the dominant nouns in your application use cases e.g. `What ingredients are used in a recipe?`, `Who is married to this person?`
The entities of your use cases will be the labeled nodes in the graph data model. In the Movie domain, we can use nouns 
in the use cases to define the labels, for example: `What people acted in a movie?` , `What person directed a movie?`,
`What movies did a person act in?`. In this case, the two node labels would be Person and Movie. The best practice 
is to define label names as CamelCase.

Node Properties are used to uniquely identify a node and answer specific details of the use cases for the application. We 
can then return the data from the query e.g.

For example in the following statements:

* We first choose a node to Anchor i.e. where to begin the query.

```
MATCH (p:Person {name: 'Tom Hanks'})-[:ACTED_IN]-(m:Movie) RETURN m
```

* Then traverse the graph (navigation).

```
MATCH (p:Person)-[:ACTED_IN]-(m:Movie {title: 'Apollo 13'})-[:RATED]-(u:User) RETURN p,u
```

* Return data from the query.
```
MATCH (p:Person {name: 'Tom Hanks'})-[:ACTED_IN]-(m:Movie) RETURN m.title, m.released
```

In the Movie graph, we use the following properties to uniquely identify our nodes: Person.tmdbId and Movie.tmdbId.
In addition to the `tmdbId` that is used to uniquely identify a node, we must revisit the use cases to determine the 
types of data a node must hold.

|           Use case	           | Steps required                                                    |
|:-----------------------------:|:------------------------------------------------------------------|
| What people acted in a movie? | Retrieve a movie by its title <br/>Return the names of the actors.|
|What person directed a movie?|Retrieve a movie by its title.<br/>Return the name of the director.|
|What movies did a person act in?|Retrieve a person by their name.<br/>Return the titles of the movies.|
|Who was the youngest person to act in a movie?|Retrieve a movie by its title.<br/>Evaluate the ages of the actors.<br/>Return the name of the actor.|
|What is the highest rated movie in a particular year according to imDB?|Retrieve all movies released in a particular year.<br/>Evaluate the imDB ratings.<br/>Return the movie title.|
|What drama movies did an actor act in?|Retrieve the actor by name.<br/>Evaluate the genres for the movies the actor acted in.<br/>Return the movie titles.|


Given the details of the steps of the use cases in the table above, here are the properties we will define for the Movie nodes:

* Movie.title (string)
* Movie.released (date)
* Movie.imdbRating (decimal between 0-10)
* Movie.genres (list of strings)

Here are the properties we will define for the Person nodes:

* Person.name (string)
* Person.born (date)
* Person.died (date)

**Note**: The died property will be optional.


### Intermediate Nodes


You sometimes find cases where you need to connect more data to a relationship than can be fully
captured in the properties. In other words, you want a relationship that connects more than two nodes.
Mathematics allows this, with the concept of a hyperedge. This is impossible in Neo4j, but a solution 
is to create intermediate nodes. You create intermediate nodes when you need to:

* **Connect more than two nodes in a single context**
* **Relate something to a relationship**
* **Share data in the graph between entities**: In many cases relationships can share data which enables your graph to 
  contain less duplicate data. Intermediate nodes also allow you to deduplicate information. 

These three use cases are used to make the graphs relationships more meaningful and sharable 
between nodes.

Consider an instance model where we have a Person and Company Nodes and a  `WORKS_AT` hyperedge that has 
the from and to properties (dates array where each value is string representing range, array of roles) and 
we need to associate the role with this period of work. In Neo4j, there is no way to create a 
relationship that connects a relationship to a third node. Neo4j relationships can only connect two nodes.
The solution is to replace the hyperedge with a connection point node. Since nodes are connection points, you simply
create a node in the middle of the hyperedge. In this example, we replace the WORKS_AT hyperedge 
with an Employment intermediate node. This provides a connection point that allows us to connect 
any amount of information to a Person's term of employment at a Company. In addition, Person nodes 
can have a shared Role or Company, and allow us to very easily trace either the full details of a 
single person’s career, or the overlap between different individuals.

## Modelling Relationships

Connections are the verbs in your use cases e.g. `What ingredients are used in a recipe?` or  `Who is married to this person?`
Choosing good names (types) for the relationships in the graph is important. Relationship types need to be something 
that is intuitive to stakeholders and developers alike. Relationship types cannot be confused with an entity name.
A relationship is typically between 2 different nodes, but it can also be to the same node.
We could define these relationship types:USES and MARRIED for the examples above. . The Neo4j best practice is to use
all capital letters/underscore characters for the name of the relationship.

When you create a relationship in Neo4j, a direction must either be specified explicitly or inferred by the 
left-to-right direction in the pattern specified. At runtime, during a query, direction is typically not required.
For example:
* The USES relationship must be created to go from a Recipe node to an Ingredient node.
* The MARRIED relationship could be created to start in either node since this type of relationship is symmetric.


Properties for a relationship are used to enrich how two nodes are related. When you define a property for a relationship,
it is because your use cases ask a specific question about how two nodes are related, not just that they are related.
We could have a date property on the MARRIED relationship to further describe the relationship between 
two people Michael and Sarah. Additionally, we can have a roles property on the WORKS_AT relationship to 
describe the roles that Michael has or had when he worked at Graph Inc.

### Refactoring to specialised relationships

Relationships are fast to traverse and they do not take up a lot of space in the graph. 
. In some cases, it is more performant to query the graph based upon relationship types, rather than properties in the nodes.


Lets look at a use case in movies example : **What movies did Tom Hanks act in for a particular year?**

```
MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
WHERE p.name = 'Tom Hanks' AND
m.released STARTS WITH '1995'
RETURN m.title AS Movie
```

The query above returns 13. What if Tom Hanks acted in 50 movies in the year 1995? The query would need to retrieve
all movies that Tom Hanks acted in and then check the value of the released property. What if Tom Hanks acted in a
total of 1000 movies? All of these Movie nodes would need to be evaluated.

Lets looks at another use case: **What actors or directors worked in a particular year?**

```
MATCH (p:Person)--(m:Movie)
WHERE  m.released STARTS WITH '1995'
RETURN DISTINCT p.name as `Actor or Director`
```

This query is even worse for performance because in order to return results, it must retrieve all Movie nodes. 
You can imagine, if the graph contained millions of movies, it would be a very expensive query.

In the previous two queries, the data model would benefit from having specialized relationships between the nodes.
So, for example, in addition to the ACTED_IN and DIRECTED relationships, we add relationships that have year information.
`ACTED_IN_1992`, `ACTED_IN_1993`, `ACTED_IN_1995`, `DIRECTED_1992`, `DIRECTED_1995`.
At first, it seems like a lot of relationships for a large, scaled movie graph, but if the latest two new queries are
important use cases, it is worth it.
In most cases where we specialize relationships, we keep the original generic relationships as existing queries
still need to use them. The code to refactor the graph to add these specialized relationships uses the APOC library.

```
MATCH (n:Actor)-[r:ACTED_IN]->(m:Movie)
CALL apoc.merge.relationship(n,
                              'ACTED_IN_' + left(m.released,4),
                              {},
                              m ) YIELD rel
RETURN COUNT(*) AS `Number of relationships merged`
```

It has a apoc.merge.relationship procedure that allows you to dynamically create relationships in the graph. 
It uses the 4 leftmost characters of the released property for a Movie node to create the name of the relationship.
As a result of the refactoring, the previous two queries can be rewritten and will definitely perform better 
for a large graph.
For the query used above to answer the use case **What movies did Tom Hanks act in for a particular year?**, the 
specific relationship is traversed, but fewer Movie nodes are retrieved.
For the query used to answer the use case **What actors or directors worked in a particular year?*, 
because now the year is in the relationship type, we do not have to retrieve any Movie nodes.

### Fanout

Here, we have entities (Person, Residence) represented not as a single node, but as a network or linked nodes.

This is an extreme example of fanout, and is almost certainly overkill for any real-life solution, but some amount of 
fanout can be very useful.
For example, splitting last names onto separate nodes helps answer the question, “Who has the last name Scott?”. 
Similarly, having cities as separate nodes assists with the question, “Who lives in the same city as Patrick Scott?”.
The main risk about fanout is that it can lead to very dense nodes, or supernodes. These are nodes that have 
hundreds of thousands of incoming or outgoing relationships Supernodes need to be handled carefully.


## Testing the model

 To ensure that the graph can satisfy every use case, you must test the use cases against the graph.

The Cypher code used to test the use cases needs to be carefully reviewed for correctness. In addition, you 
must understand that if and when the graph is refactored (next module), the Cypher code for these use cases may 
need to be modified to improve performance.

The basic testing to ensure that the use cases can be answered by the data model is the first step of testing.
Your testing will be to execute Cypher code against the instance model to verify that graph and the 
query support the use case.

A really important factor with testing the graph is scalability. How will these queries perform if the graph 
has millions of nodes or relationships? This is where you need to work with the Cypher developers to test the 
performance of the queries when the graph grows.

## Refactoring

Refactoring is the process of changing the data model and the graph.  There are three reasons why you would refactor:

1. The graph as modeled does not answer all of the use cases.
2. A new use case has come up that you must account for in your data model.
3. The Cypher for the use cases does not perform optimally, especially when the graph scales

To refactor a graph data model and a graph, you must:

* Design the new data model.
* Write Cypher code to transform the existing graph to implement the new data model.
* Retest all use cases, possibly with updated Cypher code.

Node labels serve as an anchor point for a query. By specifying a label, we are specifying a subset 
of one or more nodes with which to start a query. Using a label helps to reduce the amount of data that is retrieved.
Your goal in modeling should be to reduce the size of the graph that is touched by a query. In Cypher, you can produce
a query plan that shows what operations occur during the query. 

You should use labels wisely in your data model. They should be used if it will help with most of your use cases.  
A best practice is to limit the number of labels for a node to 4. If the use of a property for a node will suffice, 
then it is best to not have the label.

### Retesting after refactoring 

After you have refactored the graph, you should revisit all queries for your use cases. You should first determine
if any of the queries need to be rewritten to take advantage of the refactoring. Next, we rewrite some of our 
queries to take advantage of the refactoring. During your testing on your real application and especially with a
fully-scaled graph, you can also profile the new queries to see if it improves performance. On the small instance 
model we are using, you will not see significant improvements, but you may see differences in the number of 
rows retrieved.
If you have a scaled graph (with many nodes/relationships), you should also use the PROFILE keyword to compare
the performance of the queries after the refactoring.

### Avoid these labels 

You want to avoid labeling your nodes to represent hierarchies. This is often called “inheritance” or “IS-A” relationships.
You should not do this where nodes have multiple labels that represent a hierarchy
You should also avoid semantically orthogonal labels. “Semantically orthogonal” is a fancy term that means that 
labels should have nothing to do with one another. You should be careful not to use the same type of label 
in different contexts. For example, using the region for all types of nodes is not useful for most queries.

## Eliminate Duplicate data

You should take care to avoid duplicating data in your graph. Where some databases require a form of denormalization 
to improve the speed of a set of queries, this is not always the case with a graph database. De-duplicating data
gives you the added benefit of allowing you to query through a node - for example, finding other customers 
who have purchased a particular product, or finding similar movies based on the rating of other users.

In addition, duplicating data in the graph increases the size of the graph and the amount of data that may need to
be retrieved for a query. A solution here is to model properties as nodes.


### nodes with complex data

Since nodes are used to store data about specific entities, you may have initially modeled, for example,
a Production node to contain the details of the address for the production company.

Storing complex data in the nodes like this may not be beneficial for a couple of reasons:

1. Duplicate data. Many nodes may have production companies in a particular location and the data is 
   repeated in many nodes.

2. Queries related to the information in the nodes require that all nodes be retrieved.

If there is a high amount of duplicate data in the nodes or if key questions of your use cases would perform 
better if all nodes need not be retrieved to get at the complex data, then you might consider refactoring 
the graph as shown here.

In this refactoring, if there are queries that need to filter production companies by their state, 
then it will be faster to query based upon the State.name value, rather than evaluating all of the 
state properties for the Production nodes.
How you refactor your graph to handle complex data will depend upon the performance of the queries when your graph scales.

