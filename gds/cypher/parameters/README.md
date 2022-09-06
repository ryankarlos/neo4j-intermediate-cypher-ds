You can set values for Cypher parameters that will be in effect during your Neo4j Browser session.
You can set the value of a single parameter as shown in this example where the value Tom Hanks 
is set for the parameter actorName:

```
:param actorName: 'Tom Hanks'
```

After you have set the parameter, you can then successfully run the Cypher code.
In your Cypher statements, a parameter name begins with the $ symbol.

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = $actorName
RETURN m.released AS releaseDate,
m.title AS title
ORDER BY m.released DESC
```

Special consideration should be made when setting integer values in a Neo4j Browser session. Due to a discrepancy 
between integers in JavaScript and in the Neo4j type system, any integers are converted to floating point 
values when the parameter is set. This is designed to avoid any data loss on large numbers.

For example, if you run the following code to set the number parameter using colon (:) operator, the number 
will be converted from 10 to 10.0.

```
:param number: 10
```

Instead, to force the number to be an integer, you can use the ⇒ operator.

```
:param number=> 10
```


You can also use the JSON-style syntax to set all of the parameters in your Neo4j Browser session. The values you can 
specify in this object are numbers, strings, and booleans. In this example we set two parameters for our session:

```
:params {actorName: 'Tom Cruise', movieName: 'Top Gun'}
```

Here is a query that uses both parameters:

```
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = $actorName
AND m.title = $movieName
RETURN p, m
```

If you want to view the current parameters and their values, simply type `:params`
If you want to remove an existing parameter from your session, you do so by using the JSON-style syntax and 
exclude the parameter for your session.
If you want to clear all parameters, you can simply type `:params {}`