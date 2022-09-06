# Preparation for the Neo4j certification

This repository contains all the material copied over from the free [Neo4j Graph Academy courses](https://graphacademy.neo4j.com/)
 in preparation for the [Neo4j Certified Professional Certification](https://graphacademy.neo4j.com/courses/neo4j-certification/)
and [Neo4j Graph Data Science Certificaiton](https://graphacademy.neo4j.com/courses/gds-certification/)

Some of the examples also use refences from the Neo4j [Cypher](https://neo4j.com/docs/cypher-manual/current/) and 
[GDS](https://neo4j.com/docs/graph-data-science/current/) docs.

The following list of course materials have been included in this repository 

1. [Neo4j Fundamentals](https://graphacademy.neo4j.com/courses/neo4j-fundamentals/)
2. [Cypher Fundamentals](https://graphacademy.neo4j.com/courses/cypher-fundamentals/)
3. [Intermediate Cypher Queries](https://graphacademy.neo4j.com/courses/cypher-intermediate-queries/)
4. [Introduction to Neo4j Graph Data Science](https://graphacademy.neo4j.com/courses/gds-product-introduction/)
5. [Neo4j Graph Data Science Fundamentals](https://graphacademy.neo4j.com/courses/graph-data-science-fundamentals/) 
6. [Importing CSV Data into Neo4j](https://graphacademy.neo4j.com/courses/importing-data/) #TODO
7. [Graph Data Modelling Fundamentals](https://graphacademy.neo4j.com/courses/modeling-fundamentals/) #TODO 
8. [Building Neo4j Applications with Python](https://graphacademy.neo4j.com/courses/app-python/) #TODO

## Setup

To use the Neo4j inbuilt datasets on Neo4j Desktop, create new Project and then add Remote Connection.
Lets assume we want to access the movies database.

Name Movies
Connect URL: neo4j+s://demo.neo4jlabs.com
Username: movies
Password: movies

Click on save changes and connect. Then open in Neo4j browser to start running queries.

To add any other dataset, e.g. recommendations - follow the same procedure and username/password
will be the same as dataset name i.e. recommendations in this case

If you are installing a local graph DBMS, make sure to select the latest Neo4j version (4.4.10) from the 
dropdown  to be able to access the install the latest versions of the plugins discussed in the next section.
You will need to set your own password and manually load csv data into database as demostrated in the docs 
https://neo4j.com/developer/desktop-csv-import/

### Plugins

To install the various plugins like Graph Data Science Library or APOC, navigate to the plugins tab of the database
in Neo4j desktop as shown in the docs https://neo4j.com/docs/graph-data-science/current/installation/neo4j-desktop/

### Installing Python driver

To access neo4j database from applications in python, we need to install the python neo4j driver
to carry out CRUD operations as explained in the [docs](https://neo4j.com/developer/python/ )

``
pip install neo4j
``

### Graph Basics

Nodes are the entities in the graph which can be tagged with labels, representing their different roles in your domain.
They can hold any number of key-value pairs, or properties. Labels may also attach metadata such as index or constraint 
information to nodes.
A directed relationship is non-symmetrical. It goes from a source node to a target node. 
This type of relationship may contain additional qualifying properties, for example a 
weighting or strength indicator. An undirected relationship is symmetric with no directional character,
it is simply between two nodes instead of having a source and target.
Every relationship in the neo4j database is directed by design, have a type also can have properties like nodes.
Nodes can have any number or type of relationships. https://neo4j.com/developer/graph-database/


```
CALL db.schema.visualization()
```

<img src="screenshots/movies-db-schema.png">
