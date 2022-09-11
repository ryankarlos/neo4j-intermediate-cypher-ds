# Importing CSV data into Neo4j 


Cypher has a built-in clause, LOAD CSV for importing CSV files. If you have a JSON or XML file, you must use
the APOC library to import the data, but you can also import CSV with APOC. The Neo4j Data Importer 
enables you to import CSV data without writing any Cypher code.
The data in the source files may contain more data than what you need in your graph. There may not be a 
1-1 mapping of the data in a CSV file to what you would use as a node in a graph data model. In addition, 
the data in the source files may represent data types that are not supported in Neo4j or specified in 
the data model you are implementing. Some data in the source files may need to be transformed into the appropriate types.

The types of data that you can store as properties in Neo4j include: String, Long (integer values), 
Double (decimal values), Boolean, Date/Datetime, Point (spatial), StringArray (comma-separated list of strings), 
LongArray (comma-separated list of integer values) and DoubleArray (comma-separated list of decimal values)
After you understand the source data you have to work as well as the graph data model you will be implementing, 
you can import the data into Neo4j. There are two ways that you can import CSV data into Neo4j:

* Using the Neo4j Data Importer.
* Writing Cypher code to perform the import.

In both cases, the import involves reading the source data and using it to create nodes, relationships, and 
properties in the graph.

## Requirements for importing CSV data 

You must have one or more CSV files that represent the nodes and relationships that will be 
created in the graph. You must also have an existing Neo4j DBMS that is started. 
You typically start with a graph that has nothing in it.

Before importing data into Neo4j make sure you understand the data in the source CSV files and 
the graph data model you will be implementing during the import. Inspect and clean (if necessary) the data 
in the source data files before importing.

## Understanding and Inspecting the Source Data

When you are given CSV files, you must determine whether the CSV file will have header information, 
describing the names of the fields and what the delimiter will be for the fields in each row. Including headers in 
the CSV file reduces syncing issues and is a recommended Neo4j best practice.

Data normalization is common in relational models. This enables you to have CSV files that correspond to a relational
table where an ID is used to identify the relationships. With de-normalized data, the data is represented by 
multiple rows corresponding to the same entity, which will be loaded as a node. The difference, however, is 
that de-normalized data typically represents data from multiple tables in the RDBMS. For example, the movie and person
data (including the ID) is repeated in multiple rows in the file, but a row represents a particular actor’s role in 
a particular movie. That is, a Movie and Person data will be represented in multiple rows, but an actor’s role will
be represented by a single row.

When you load data from CSV files, you rely heavily upon the IDs specified in the file. A Neo4j best practice is to
use an ID as a unique property value for each node. If the IDs in your CSV file are not unique for the same entity 
(node), you will have problems when you load the data and try to create relationships between existing nodes.

Before you start working with the source CSV data, you must understand how delimiters, quotes, and special characters 
are used for each row. If the headers do not correspond to the data representing the fields, you cannot load the data.
You must also know whether you can assume the use of the default delimiter ",", otherwise, you will need to use the
FIELDTERMINATOR keyword along with LOAD CSV when you use Cypher to import the data. You should have a local copy of the
CSV files so you can inspect the data in them. In fact, when using the Neo4j Data Importer you will need a local copy
of the CSV files.

* If the CSV file is a URL, you can simply download it in a Web browser and save it locally.
* You should view the contents (at least the beginning rows) of the file to determine the delimiter.For example, to
  check if the CSV file indeed has a header row and the delimiter is a comma. Do the fields  have quotes around values
  that are strings ? 
* Depending on the length of each row, it may be hard to determine if the values for fields look consistent. 
  With a CSV file, you can open it in a spreadsheet to understand the data a little better. By default all of these 
  fields in each row will be read in as string types. The csv file may contain a multi-value field such as countries 
  or languages which have values delimited by the "|" character.
* You must make sure that all records can be read from the CSV file without error. 
  Here is the Cypher code that will read all data in a CSV file that contains headers and is specified as a URL:
  
```
  LOAD CSV WITH HEADERS
  FROM 'https://data.neo4j.com/importing/ratings.csv'
  AS row
  RETURN count(row)
```

It will read every row from the CSV file and will return the number of rows successfully read. If an error occurs 
during the reading of the CSV file, an error will be raised 

Here are some additional things that you will check before you begin working with the data, depending on the data:

* Are quotes used correctly?
* If an element has no value will an empty string be used?
* Are UTF-8 prefixes used (for example \uc)?
* Do some fields have trailing spaces?
* Do the fields contain binary zeros?
* Understand how lists are formed (default is to use colon(:) as the separator.
* Any obvious typos?

## Neo4j importer

The Neo4j importer a graph app the allows you to import CSV files from your local system into the graph.
It can be accessed  [here](https://data-importer.graphapp.io/?acceptTerms=true). With this graph app, you can examine 
the CSV file headers, and map them to nodes and relationships in a Neo4j graph.
After you have defined the mapping, you connect to a running Neo4j DBMS to perform the import. The benefit of the Data 
Importer is that you need not know Cypher to load the data.
It is useful for loading small to medium CSV files that contain fewer that 1M rows. 
Data that is imported into the graph can be interpreted as string, integer, float, or boolean data. If a field in a 
row needs to be stored in the graph as a date or list, it will be by default stored in the graph as a string and 
you will need to post-process the graph after the import. 

The requirements for using the Data Importer are the following:

* You must use CSV files for import.
* CSV files must reside on your local system so you can load them into the graph app.
* CSV data must be clean (you learned this in an earlier lesson).
* IDs must be unique for all nodes you will be creating.
* The CSV file must have headers.
* The DBMS must be started.

After you have run the import of the Data Importer, it is important that you review the graph results. 
The most important behavior of the Data Importer you must understand is that property values are written as strings, 
Longs (integer values), Doubles (decimal values), or Booleans. In addition, the Data Importer creates uniqueness 
constraints on all nodes based upon the unique ID you specified for each node.

## Refactoring Imported Data

You can use Cypher to refactor the data imported with Neo4j Data Importer. We may need to do the following: 

* Transforming data types from string to a date or a multi-value list of strings.
* Adding additional labels to a node.
* Adding more constraints per the graph data model.
* Creating new nodes from the data in existing node properties.]

### Transforming string properties to dates

To convert a string to a date value, we use date(property). One caveat of the date() function is that it does not work 
for empty strings or strings that do not have the correct format. For example "abc" is not a correct string 
format for a date.A correct format for a date string could be "yyyy-mm-dd". 
Additionally we can test whether the value of the property is an empty string. If it is, we remove it (set it to null).
Otherwise, we transform the string to a date. Consider the query below. Since both the born and died properties
could contain empty strings (""), we will need to transform these properties correctly.

```
MATCH (p:Person)
SET p.born = CASE p.born WHEN "" THEN null ELSE date(p.born) END
WITH p
SET p.died = CASE p.died WHEN "" THEN null ELSE date(p.died) END
```

As you move closer to the data model, you may want to confirm that the properties in the graph represent the types 
in the data model. You can use this Cypher code to show the stored type for the node properties in the graph:

```
CALL apoc.meta.nodeTypeProperties()
YIELD nodeType, propertyName, propertyTypes
```

### Transforming multi-value properties 

A multi-value property is a property that can hold one or more values. This type of data in Neo4j is represented as a list. All values in a list must have the same type. For example:
* ["USA", "Germany", "France"]
* [100, 55, 4]

Transforming multi-value fields as lists can be done as follows where we use two Cypher built-in functions to help us:

```
MATCH (m:Movie)
SET m.countries = split(coalesce(m.countries,""), "|"),
m.languages = split(coalesce(m.languages,""), "|"),
m.genres = split(coalesce(m.genres,""), "|")
```

`coalesce()` returns an empty string if the entry in m.countries is null. `split()` identifies each element in the 
multi-value field where the "|" character is the separator and create a list of each element. 
The three list properties should be transformed to the type `StringArray`.

### Adding Labels

We may need to have specific labels which is a best practice so that key queries will perform better,
especially when the graph is large. For example, If a person acted in a movie, then they will be 
labeled as an actor. If a person directed a movie, they will be labeled as a director. Here is the code that 
we can use the add the Actor label to all nodes that have the ACTED_IN relationship:

```
MATCH (p:Person)-[:ACTED_IN]->()
WITH DISTINCT p SET p:Actor
```

### Uniqueness constraint and refactoring Properties as Nodes

When you used the Data Importer, it automatically created the uniqueness constraints in the graph for the unique IDs 
you specified when you imported the data. You can view the constraints defined in the graph with the SHOW 
CONSTRAINTS command in Neo4j Browser.
A best practice is to always have a unique ID for every type of node in the graph. We want to also have a uniqueness
constraint for the Genre nodes we will be creating in the graph. Having a uniqueness constraint defined helps 
with performance when creating nodes and also for queries. The MERGE clause looks up nodes using the property 
value defined for the constraint. With a constraint, it is a quick lookup and if the node already exists, it is 
not created. 

Here is the code we can use to create this uniqueness constraint for the name property of Genre nodes:

```
CREATE CONSTRAINT Genre_name ON (g:Genre) ASSERT g.name IS UNIQUE
```

Now we will turn a property of type list into a set of nodes with relationships.
For example, the query below will retrieve all Movie nodes and use the values in the genres property
to create the Genre node if it does not already exist and point to it with the IN_GENRE relationship.

```
MATCH (m:Movie)
UNWIND m.genres AS genre
WITH m, genre
MERGE (g:Genre {name:genre})
MERGE (m)-[:IN_GENRE]->(g)
```


The UNWIND clause expands the elements in properties list for the node as rows. With this data, it creates the new node
using MERGE. With MERGE, it only creates the node if it does not already exist. Then it creates the relationship 
between the source node and the target node. Then you will need to simply remove the property from the graph.

We can view the visualization of the schema to confirm that it matches our data model.

```
CALL db.schema.visualisation
```


## Importing large datasets with cypher

As you learned earlier, the Data Importer can be used for small to medium datasets containing less than 1M rows. 
The Data Importer is a generalized app as you saw that creates all properties in the graph as strings, integers, 
decimals, or boolean, and you need to possibly post-process or refactor the graph after the import. It is also 
designed to handle a smaller memory footprint, so it may not be useful for all of your data import needs.

When you import using Cypher statements, you have control over the amount of memory used for the import. In 
Cypher, by default, the execution of your code is a single transaction. In order to process large CSV imports, 
you need to break up the execution of the Cypher into multiple transactions.

You can use this code structure using `USING PERIODIC COMMIT` to import a large dataset:

```
USING PERIODIC COMMIT LOAD CSV WITH HEADERS
FROM 'url-for-CSV-file'
AS row
/// add data to the graph for each row
```

The default transaction size for this type of import is 500 rows. That is, after 500 rows have been read from the CSV 
file, the data will be committed to the graph and the import will continue. This enables you to load extremely large 
CSV files into the graph without running out of memory.
**Note** In Neo4j Browser, you must prefix this Cypher with :auto, that is :auto USING PERIODIC COMMIT LOAD CSV ... 
This tells Neo4j to use automatic detection of transactions.

One advantage of using Cypher for loading your CSV data is that you can perform the type transformations and some of 
the "refactoring" during the import. That is, you can customize how property types are managed so you need not do any 
post-processing after the load. You must inspect and possibly clean the data before you import it. Neo4j recommend 
multiple passes to process the CSV file. The advantage of performing the import in multiple passes is that you can 
check the graph after each import to see if it is getting closer to the data model. Hoewver, if the CSV file were 
extremely large, you might want to consider a single pass.
