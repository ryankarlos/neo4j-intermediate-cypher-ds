

// ------------------- Duration ----------------


// Execute this code to create or update the Test node with these date and datetime values

MERGE (x:Test {id: 1})
SET
x.date = date(),
x.datetime = datetime(),
x.timestamp = timestamp(),
x.date1 = date('2022-04-08'),
x.date2 = date('2022-09-20'),
x.datetime1 = datetime('2022-02-02T15:25:33'),
x.datetime2 = datetime('2022-02-02T22:06:12')
RETURN x

// Write a query to retrieve this Test node and calculate the number of days between date1 and date2.
// 165 days

MATCH (x:Test)
RETURN duration.InDays(x.date1, x.date2).days

// Write a query to retrieve this Test node and calculate the number of minutes between datetime1 and datetime2.
// 400 mins

MATCH (x:Test)
RETURN duration.between(x.datetime1, x.datetime2).minutes