
// find the number of (:Person) nodes who have a [:DIRECTED] relationship to the Cloud Atlas (:Movie) node.
// 3

MATCH (m:Movie {title: 'Cloud Atlas'})<-[:DIRECTED]-(p:Person)
RETURN count(p)


// ---------------- Testing equality ------------------------

// Write and execute a query to return the names of directors of horror movies released in the year 2000.

MATCH (p:Person)-[:DIRECTED]->(m:Movie)-[]-(g:Genre)
WHERE m.year =2000 AND g.name = "Horror"
RETURN p.name


// ------------------- checking null values ---------------------

// titles of all movies that do not have poster

MATCH (m:Movie)
WHERE m.poster IS NULL
RETURN m.title

// ------------------- range query  ---------------------

// people born in the 1950’s (1950 - 1959) that are both Actors and Directors.

// -- returns 80 records

MATCH (p:Person)
WHERE 1950 <= p.born.year < 1960
AND (p:Actor AND p:Director)
RETURN p.name


// ----------------------testing list inclusion ----------------------------------------

// write query to return distinct list of people who both acted and directed movie released in german language

MATCH (p:Person)-[r:ACTED_IN]-(m:Movie)
MATCH (p)-[:DIRECTED]-(m)
WHERE 'German' IN m.languages
RETURN p,m


// This should return 3 records : "Werner Herzog","Rainer Werner Fassbinder","Claude Lanzmann"


// ---------------------------------- CAse Insensitve Search ----------------------

// Write and execute a query to return all Movie titles in the graph that have a title that begins with "Life is".
// There may be titles that do not adhere to capitalization as such so you must ensure that all titles will match.
// -- this will return 4 records ------

MATCH (m:Movie)
WHERE toLower(m.title) STARTS WITH "life is"
RETURN m.title


// ---------------------------------- Contains Predicate ----------------------------------

// Write and execute a query to return the name of the person, their role, and the movie title where the role
// played by the actors or director had a value that included 'dog' (case-insensitive)? That is, the role could contain "Dog", "dog", or even "DOG".
/// -- should return 27 records

MATCH (p)-[r]-(m:Movie)
WHERE toLower(r.role) CONTAINS "dog"
AND ("Actor" IN labels(p) OR "Director" IN labels(p))   // or alternatively ' AND (p:Actor or p:Director)'
RETURN p.name, r.role, m.title


// ------------------------------------ testing patterns ---------------------------------


// Write and execute a query to return the titles of all movies that Rob Reiner directed, but did not act in.
// 14 records returned


MATCH (p)-[r:DIRECTED]-(m:Movie)
WHERE p.name = "Rob Reiner"
AND NOT exists((p)-[:ACTED_IN]-(m))
RETURN DISTINCT m.title


// ---------------------------------- multiple and optional  match  ------------------------------------

// query that returns the titles of all Film Noir movies and the users who rated them.
// 1140 rows returned

MATCH (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name = 'Film-Noir'
MATCH (m)<-[:RATED]-(u:User)
RETURN m.title, u.name

// Modify the above query so that the test for users who rated the movie are optional.
// this returns 1152

MATCH (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name = 'Film-Noir'
OPTIONAL MATCH (m)<-[:RATED]-(u:User)
RETURN m.title, u.name


// return all the properties for movies that Woody ALlen directed and add an additional property value 'true'

MATCH (m:Movie)<-[:DIRECTED]-(d:Director)
WHERE d.name = 'Woody Allen'
RETURN m {.*, favorite: true} AS movie

// ---------------------------- conditionally return data -----------------------

// return the movies that Charlie Chaplin has acted in and the runtime for the movie.
// return "Short" for runTime if the movie’s runtime is < 120 (minutes) and "Long" for runTime if the movie’s runtime is >= 120.

// gives 9 rows of which 6 are short movies

MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE p.name = 'Charlie Chaplin'
RETURN m.title AS movie,
CASE WHEN m.runtime < 120 THEN "Short"
ELSE "Long"
END AS  runTime
ORDER BY runTime DESC


/// --------------------------------------- Creating, Updating and Deleting Nodes, Relationships, Properties -------------------

// Create a new Person node for actor named Daniel Kaluuya.

MERGE (p:Person {name:"Daniel Kaluuya"})
RETURN p

// Find the Person node for Daniel Kaluuya.
// Create the Movie node, Get Out.
// Add the ACTED_IN relationship between Daniel Kaluuya and the movie, Get Out.

MATCH (p:Person {name:"Daniel Kaluuya"})
MERGE (n:Movie {title: "Get Out"})
MERGE (p)-[:ACTED_IN]-(n)


// add the tagline and released properties for the node you just created above. Set tagline to 'Gripping, scary, witty and timely!'
 and released property value to 2017

MATCH (m:Movie {title: 'Get Out'})
SET m.tagline ="Gripping, scary, witty and timely!", m.released = 2017
RETURN m.title, m.tagline, m.released

// use MERGE processing for the Movie node with the title Rocketman.
// If the node already exists (ON MATCH SET clause):Set the matchedAt property for the node referenced by m to datetime().
// If the node does not exist (ON CREATE SET clause): Set the createdAt property to datetime().
// For either case: Set the updatedAt property to datetime().
// Execute your code twice to ensure that the the MERGE processing occurs. That is, the newly created node will have a
// createdAt property and the updated node will have a matchedAt property. In both cases, the node will have the updatedAt property set.

MERGE (m:Movie {title: 'Rocketman'})
ON MATCH SET m.matchedAt = datetime()
ON CREATE SET m.createdAt = datetime()
SET  m.updatedAt=datetime()
RETURN m

// Write the code to delete the person node corresponding to  "Emil Eifrem" which was incorrectly included in the graph.

MATCH (p:Person {name: "Emil Eifrem"})
DETACH DELETE p