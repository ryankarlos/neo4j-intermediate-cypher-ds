// How many relationships are traversed to return the result using the query below?


MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN]->(m:Movie),(coActors:Person)-[:ACTED_IN]->(m)
RETURN m.title, collect(coActors.name)

// 	   p.name        m.title	       collect(coActors.name)
// "Robert Blake" "Money Train"	["Wesley Snipes", "Woody Harrelson", "Jennifer Lopez"]
// "Robert Blake" "Paul Williams Still Alive"	["Paul Williams", "Warren Beatty", "Karen Carpenter"]
// "Robert Blake" "In Cold Blood"	["John Forsythe", "Paul Stewart", "Scott Wilson"]
// "Robert Blake" "Electra Glide in Blue"	["Billy Green Bush", "Jeannine Riley", "Mitchell Ryan"]

// if we look at the result - the query finds each movie that Robert Blake acted in. That is 4 ACTED_IN traversals
// For each movie, it then finds all actors to acted in that movie (3 traversals for each movie). It does not traverse the ACTED_IN relationship from Robert Blake twice.
// This query traverses a total of 16 ACTED_IN relationships


// Given this query and what you have learned about graph traversal:
// How many relationships are traversed to return the result?

MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN]->(m:Movie)
MATCH (allActors:Person)-[:ACTED_IN]->(m)
RETURN m.title, collect(allActors.name)

// Looking at the output below, applying the logic explained in the previous query answer, this will give 20 traversals

// 	  p.name	      m.title	             collect(allActors.name)
// "Robert Blake"	"Money Train"	["Wesley Snipes", "Robert Blake", "Woody Harrelson", "Jennifer Lopez"]
// "Robert Blake"	"Paul Williams Still Alive"	["Paul Williams", "Robert Blake", "Warren Beatty", "Karen Carpenter"]
// "Robert Blake"	"In Cold Blood"	["John Forsythe", "Paul Stewart", "Robert Blake", "Scott Wilson"]
// "Robert Blake"	"Electra Glide in Blue"	["Billy Green Bush", "Robert Blake", "Jeannine Riley", "Mitchell Ryan"]


// Write and execute the query to return the names of actors that are 2 hops away from Robert Blake using the ACTED_IN relationship.
// 12 records

MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN*2]-(others:Person)
RETURN  others.name

// Write and execute the query to return the names of actors that are upto 4 hops away from Robert Blake using the ACTED_IN relationship.

MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN*1..4]-(others:Person)
RETURN  others.name