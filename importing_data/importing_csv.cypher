
// How many rows are in this CSV file: https://data.neo4j.com/importing/ratings.csv
// 3494 rows

LOAD CSV WITH HEADERS FROM 'https://data.neo4j.com/importing/ratings.csv' AS line
RETURN count(line) AS count


MATCH (p:Person)
SET p.born = CASE p.born WHEN '' THEN null ELSE date(p.born) END
WITH p
SET p.died = CASE p.died WHEN '' THEN null ELSE date(p.died) END


// Now that you have transformed properties in the graph to match what we want for
// numeric and date values in the graph, confirm that their types are correct:

CALL apoc.meta.nodeTypeProperties()
YIELD nodeType, propertyName, propertyTypes


// -------------------- Importing csv data with cypher ------


// Delete all existing data in graph
MATCH (n) DETACH DELETE n

// ensure constraints exists in model

// You must have four uniqueness constraints defined for:

//Person.tmdbId
//Movie.movieId
//User.userId
//Genre.name

SHOW CONSTRAINTS

// import movies data

LOAD CSV WITH HEADERS
FROM 'https://data.neo4j.com/importing/2-movieData.csv'
AS row
//process only Movie rows
WITH row WHERE row.Entity = "Movie"
RETURN
toInteger(row.tmdbId),
toInteger(row.imdbId),
toFloat(row.imdbRating),
row.released,
row.title,
toInteger(row.year),
row.poster,
toInteger(row.runtime),
split(coalesce(row.countries,""), "|"),
toInteger(row.imdbVotes),
toInteger(row.revenue),
row.plot,
row.url,
toInteger(row.budget),
split(coalesce(row.languages,""), "|"),
split(coalesce(row.genres,""), "|")
LIMIT 10

// import person data

LOAD CSV WITH HEADERS
FROM 'https://data.neo4j.com/importing/2-movieData.csv'
AS row
WITH row WHERE row.Entity = "Person"
RETURN
row.tmdbId,
row.imdbId,
row.bornIn,
row.name,
row.bio,
row.poster,
row.url,
CASE row.born WHEN "" THEN null ELSE date(row.born) END,
CASE row.died WHEN "" THEN null ELSE date(row.died) END
LIMIT 10


// import user data

LOAD CSV WITH HEADERS
FROM 'https://data.neo4j.com/importing/2-ratingData.csv'
AS row
RETURN
row.movieId,
row.userId,
row.name,
toInteger(row.rating),
toInteger(row.timestamp)
LIMIT 100

// import acted_in relationship

LOAD CSV WITH HEADERS
FROM 'https://data.neo4j.com/importing/2-movieData.csv'
AS row
WITH row WHERE row.Entity = "Join" AND row.Work = "Acting"
RETURN
toInteger(row.tmdbId),
toInteger(row.movieId),
row.role
LIMIT 10

// import directed relationships

LOAD CSV WITH HEADERS
FROM 'https://data.neo4j.com/importing/2-movieData.csv'
AS row
WITH row WHERE row.Entity = "Join" AND row.Work = "Directing"
RETURN
row.tmdbId,
row.movieId,
row.role
LIMIT 10

// create users and RATED relationships

LOAD CSV WITH HEADERS
FROM 'https://data.neo4j.com/importing/2-ratingData.csv'
AS row
RETURN
toInteger(row.movieId),
toInteger(row.userId),
row.name,
toInteger(row.rating),
toInteger(row.timestamp)
LIMIT 100


// ------------------------- Transform string properties -------

// transform properties to dates
// 888 properties

MATCH (p:Person)
SET p.born = CASE p.born WHEN "" THEN null ELSE date(p.born) END
WITH p
SET p.died = CASE p.died WHEN "" THEN null ELSE date(p.died) END


// view node and relationship types stored in graph

CALL apoc.meta.nodeTypeProperties()
YIELD nodeType, propertyName, propertyTypes

CALL apoc.meta.relTypeProperties()
YIELD relType, propertyName, propertyTypes


// ------------------------- Transform strings to lists  -------


// transform movie properties to lists
// code should have set 279 properties.
MATCH (m:Movie)
SET m.countries = split(coalesce(m.countries,""), "|")
SET m.genres = split(coalesce(m.genres,""), "|")
SET m.languages = split(coalesce(m.languages,""), "|")


// view types stored in the graph
CALL apoc.meta.nodeTypeProperties()
YIELD nodeType, propertyName, propertyTypes


// ------------------------ add labels to graphs

// add the actor labels
MATCH (p:Person)-[:ACTED_IN]->()
WITH DISTINCT p SET p:Actor

// add the directorlabels
MATCH (p:Person)-[:DIRECTED]->()
WITH DISTINCT p SET p:Director

// examine new labels
CALL apoc.meta.nodeTypeProperties()
YIELD nodeType, propertyName, propertyTypes


// -------------------------- create genre nodes -------


// add the uniqueness constraint to the genre node in the graph
CREATE CONSTRAINT Genre_name ON (g:Genre) ASSERT g.name IS UNIQUE


// create the Genre nodes in the graph, and the IN_GENRE relationships
// this should create 17 Genre nodes and 212 IN_GENRE relationships.
MATCH (m:Movie)
UNWIND m.genres AS genre
WITH m, genre
MERGE (g:Genre {name:genre})
MERGE (m)-[:IN_GENRE]->(g)

// Now that we have the Genre nodes, we no longer need the genres property in the Movie nodes.
// remove the genres property.
// should set 93 properties.
MATCH (m:Movie)
SET m.genres = null


// view the final schema
CALL db.schema.visualization