
// ------------------- Duplicate Data -----------------


// Duplicating data in the graph can be expensive.
// To illustrate duplication of data, we will add a languages property to each Movie node in the instance model.

MATCH (apollo:Movie {title: 'Apollo 13', tmdbId: 568, released: '1995-06-30', imdbRating: 7.6, genres: ['Drama', 'Adventure', 'IMAX']})
MATCH (sleep:Movie {title: 'Sleepless in Seattle', tmdbId: 858, released: '1993-06-25', imdbRating: 6.8, genres: ['Comedy', 'Drama', 'Romance']})
MATCH (hoffa:Movie {title: 'Hoffa', tmdbId: 10410, released: '1992-12-25', imdbRating: 6.6, genres: ['Crime', 'Drama']})
MATCH (casino:Movie {title: 'Casino', tmdbId: 524, released: '1995-11-22', imdbRating: 8.2, genres: ['Drama','Crime']})
SET apollo.languages = ['English']
SET sleep.languages =  ['English']
SET hoffa.languages =  ['English', 'Italian', 'Latin']
SET casino.languages =  ['English']


//  Use Case: What movies are available in a particular language?
// we find all movies in Italian.
// this returns one movie Hoffa


MATCH (m:Movie)
WHERE 'Italian' IN m.languages
RETURN m.title


// Refactor the graph to turn the languages property values into Language nodes

MATCH (m:Movie)
UNWIND m.languages AS language
WITH  language, collect(m) AS movies
MERGE (l:Language {name:language})
WITH l, movies
UNWIND movies AS m
WITH l,m
MERGE (m)-[:IN_LANGUAGE]->(l);
MATCH (m:Movie)
SET m.languages = null

// modify the cypher statement to return the result for the use case based on new data model

MATCH (m:Movie)-[:IN_LANGUAGE]-(l:Language)
WHERE  l.name = 'Italian'
RETURN m.title


// Adding Genre nodes

// This query should return the movies Apollo 13 and Sleepless in Seattle.

MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
WHERE p.name = 'Tom Hanks' AND
'Drama' IN m.genres
RETURN m.title AS Movie


// 1. Modify and run the query  to use the data in the genres property for
// the Movie nodes and create Genre nodes using the IN_GENRE relationship to connect Movie nodes to Genre nodes.


MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
UNWIND m.genres as genre
MERGE (g:Genre {name:genre})
MERGE (g)<-[:IN_GENRE]-(m)
WITH g, m
RETURN m, g;

// 2. Delete the genres property from the Movie nodes.

MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
WHERE exists(m.genres)
REMOVE m.genres

// 3. Rewrite the query for the use case: What drama movies did an actor act in?

// It should return the movies Apollo 13 and Sleepless in Seattle.

MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)-[:IN_GENRE]->(g:Genre {name:'Drama'})
WHERE p.name = 'Tom Hanks'
RETURN m.title