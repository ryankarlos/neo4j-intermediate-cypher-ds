

// You have been given the following query which finds all users with a name beginning with the string value supplied in the $name parameter.


MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name STARTS WITH $name
RETURN p.name AS actor,
m.title AS title

// What command would you run in Neo4j Browser to set the $name parameter to Tom? (use double-quotes for the value of the parameter)

:param name: "Tom"

// Now we have another parameter `$country`

MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name STARTS WITH $name
AND $country IN m.countries
RETURN p.name AS actor,
m.title AS title


// Add both values for parameters before running the query above

:params {name: "Tom", country: "UK"}


