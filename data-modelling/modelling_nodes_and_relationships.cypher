// ---------------------------------- Modelling Nodes --------------------------------

// Run the Cypher code below to add the Person and Movie nodes to the graph which will serve as our initial instance model.
// first remove any existing nodes in graph
MATCH (n) DETACH DELETE n;

MERGE (:Movie {title: 'Apollo 13', tmdbId: 568, released: '1995-06-30', imdbRating: 7.6, genres: ['Drama', 'Adventure', 'IMAX']})
MERGE (:Person {name: 'Tom Hanks', tmdbId: 31, born: '1956-07-09'})
MERGE (:Person {name: 'Meg Ryan', tmdbId: 5344, born: '1961-11-19'})
MERGE (:Person {name: 'Danny DeVito', tmdbId: 518, born: '1944-11-17'})
MERGE (:Person {name: 'Jack Nicholson', tmdbId: 514, born: '1937-04-22'})
MERGE (:Movie {title: 'Sleepless in Seattle', tmdbId: 858, released: '1993-06-25', imdbRating: 6.8, genres: ['Comedy', 'Drama', 'Romance']})
MERGE (:Movie {title: 'Hoffa', tmdbId: 10410, released: '1992-12-25', imdbRating: 6.6, genres: ['Crime', 'Drama']})

// You can verify that the nodes have been created by running this code:

MATCH (n) RETURN n

// We want to add a couple of User nodes to the graph so we can test the changes to our model.
// create two User nodes for: 'Sandy Jones' with the userId of 534 and 'Clinton Spencer' with the userId of 105

MERGE (u:User {userId: 534})
MERGE (p:User {userId:105})
SET u.name = "Sandy Jones"
SET p.name = "Clinton Spencer"


// -------------------------------------------Modelling Relationships -------------------------------

// We will add relationships between specific nodes created previously

MATCH (apollo:Movie {title: 'Apollo 13'})
MATCH (tom:Person {name: 'Tom Hanks'})
MATCH (meg:Person {name: 'Meg Ryan'})
MATCH (danny:Person {name: 'Danny DeVito'})
MATCH (sleep:Movie {title: 'Sleepless in Seattle'})
MATCH (hoffa:Movie {title: 'Hoffa'})
MATCH (jack:Person {name: 'Jack Nicholson'})

// create the relationships between nodes
MERGE (tom)-[:ACTED_IN {role: 'Jim Lovell'}]->(apollo)
MERGE (tom)-[:ACTED_IN {role: 'Sam Baldwin'}]->(sleep)
MERGE (meg)-[:ACTED_IN {role: 'Annie Reed'}]->(sleep)
MERGE (danny)-[:ACTED_IN {role: 'Bobby Ciaro'}]->(hoffa)
MERGE (danny)-[:DIRECTED]->(hoffa)
MERGE (jack)-[:ACTED_IN {role: 'Jimmy Hoffa'}]->(hoffa)

// verify that the relationships have been created with this code:
// There should be a total of 6 relationships in the graph.

MATCH (n) RETURN n


// create RATED relationships that include the rating property.
//create one relationship between Sandy Jones and Apollo 13 with a rating of 5.
// Add additional MERGE code to create the remaining 4 relationships as below:
//   User.name      Relationship  Rating    Movie.title
// 'Sandy Jones'       RATED        5       'Apollo 13'
// 'Sandy Jones'       RATED        4       'Sleepless in Seattle'
// 'Clinton Spencer'   RATED        3       'Apollo 13'
// 'Clinton Spencer'   RATED        3       'Sleepless in Seattle'
// 'Clinton Spencer'   RATED        3       'Hoffa'


MATCH (sandy:User {name: 'Sandy Jones'})
MATCH (clinton:User {name: 'Clinton Spencer'})
MATCH (apollo:Movie {title: 'Apollo 13'})
MATCH (sleep:Movie {title: 'Sleepless in Seattle'})
MATCH (hoffa:Movie {title: 'Hoffa'})
MERGE (sandy)-[:RATED {rating:5}]->(apollo)
MERGE (sandy)-[:RATED {rating:4}]->(sleep)
MERGE (clinton)-[:RATED {rating:3}]->(apollo)
MERGE (clinton)-[:RATED {rating:3}]->(sleep)
MERGE (clinton)-[:RATED {rating:3}]->(hoffa)


// ------------------ specialised relationshps --------------

// Execute the following code to create a new set of relationships based on the year of the released property for each Node.
// For example, Apollo 13 was released in 1995, so an additional ACTED_IN_1995 will be created between Apollo 13 and any actor that acted in the movie.
// It should create 5 relationships.

MATCH (n:Actor)-[:ACTED_IN]->(m:Movie)
CALL apoc.merge.relationship(n,
  'ACTED_IN_' + left(m.released,4),
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`;

// Modify the code you have just run to match the following pattern.` MATCH (n:Director)-[:DIRECTED]→(m:Movie)``
// Then modify the procedure call change the prefix of the relationship to `DIRECTED_`
// It should create 2 relationships.

MATCH (n:Director)-[:DIRECTED]->(m:Movie)
CALL apoc.merge.relationship(n,
  'DIRECTED_' + left(m.released,4),
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`;


// It should return Tom Hanks and Martin Scorsese.
MATCH (p:Person)-[:ACTED_IN_1995|DIRECTED_1995]->()
RETURN p.name as `Actor or Director`


// Modify this query to use the -[:RATED]->()
// relationship to  create a new RATED_{rating}
// relationship between the :User and a :Movie
MATCH (n:Actor)-[:ACTED_IN]->(m:Movie)
CALL apoc.merge.relationship(n,
  'ACTED_IN_' + left(m.released,4),
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`

// modified query below will give 5 relationships

MATCH (n:User)-[r:RATED]->(m:Movie)
CALL apoc.merge.relationship(n,
  'RATED_' + r.rating,
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`


// ---------------- intermediate nodes ------------------

// We want to infer more from the roles that an actor played in a movie.
// The same role could be repeated in multiple movies. Furthermore, we might want
// to add how different roles interact with each other in the same movie or between movies.


// Find an actor that acted in a Movie (MATCH (a:Actor)-[r:ACTED_IN]→(m:Movie))
// Create (using MERGE) a Role node setting it’s name to the role in the ACTED_IN relationship.
// Create (using MERGE) the PLAYED relationship between the Actor and the Role nodes.
// Create (using MERGE) the IN_MOVIE relationship between the Role and the Movie nodes.

// Your code should create 5 nodes and 10 relationships.


MATCH (a:Actor)-[r:ACTED_IN]->(m:Movie)
MERGE (p:ROLE {name:r.role})
MERGE (a)-[:PLAYED]->(p)-[:IN_MOVIE]->(m)
RETURN a, p, m

