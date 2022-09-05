


## Dates and Times
Cypher has these basic formats for storing date and time data - `date(), datetime(), time()`

There are a number of other types of data such as Time, LocalTime, LocalDateTime, Timestamp, and Duration which are 
described in the Temporal Functions section of the Neo4j Cypher Manual. https://neo4j.com/docs/cypher-manual/current/functions/temporal/

create some date/time properties. Execute the following code to create a node in the graph containing these types:
```
MERGE (x:Test {id: 1})
SET x.date = date(),
    x.datetime = datetime(),
    x.time = time()
RETURN x
```

Next, execute this code that will show the types of the properties in the graph:

```
CALL apoc.meta.nodeTypeProperties()
```

Notice the types for properties stored in the graph. The graph has Person data of type Date and you have added properties
of type DateTime and Time.


### Extracting components of a date or datetime
You can access the components of a date or datetime property:

```
MATCH (x:Test {id: 1})
RETURN x.date.day, x.date.year,
x.datetime.year, x.datetime.hour,
x.datetime.minute
```
 ### Setting date values

You can use a string to set a value for a date:

```
MATCH (x:Test {id: 1})
SET x.date1 = date('2022-01-01'),
    x.date2 = date('2022-01-15')
RETURN x
```

### Setting datetime values
ou can use a string to set a value for a datetime:

```
MATCH (x:Test {id: 1})
SET x.datetime1 = datetime('2022-01-04T10:05:20'),
    x.datetime2 = datetime('2022-04-09T18:33:05')
RETURN x
```
### Working with durations 

A duration is used to determine the difference between two date/datetime values or to add or subtract a duration to a value.

This code returns the duration between date1 and date2 in the graph:

```
MATCH (x:Test {id: 1})
RETURN duration.between(x.date1,x.date2)
```

It returns a duration value that represents the days and months and times between the two values. In this case, the
duration between date1 and date2 is 14 days.

We can return the duration in days between two datetime values:

```
MATCH (x:Test {id: 1})
RETURN duration.inDays(x.datetime1,x.datetime2).days
```

We can add a duration of 6 months:

```
MATCH (x:Test {id: 1})
RETURN x.date1 + duration({months: 6})
```

### Using APOC to format dates and times
The APOC library has many useful functions for working with all types of data.

Here is one way you can use APOC to format a datetime:

```
MATCH (x:Test {id: 1})
RETURN x.datetime as Datetime,
apoc.temporal.format( x.datetime, 'HH:mm:ss.SSSS')
AS formattedDateTime
```

or another way

```
MATCH (x:Test {id: 1})
RETURN apoc.date.toISO8601(x.datetime.epochMillis, "ms")
AS iso8601
```


**Note** You can also use apoc.temporal.toZonedTemporal() for parsing arbitrary formatted temporal values with a format string.

