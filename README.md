# Preparation for the Neo4j certification

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

A directed relationship is non-symmetrical. It goes from a source node to a target node. 
This type of relationship may contain additional qualifying properties, for example a 
weighting or strength indicator.

An undirected relationship is symmetric with no directional character, it is simply between 
two nodes instead of having a source and target.

Every relationship in the neo4j database is directed by design. ]

```
CALL db.schema.visualization()
```

<img src="screenshots/movies-db-schema.png'>