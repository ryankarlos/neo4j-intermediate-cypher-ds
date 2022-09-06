from neo4j import GraphDatabase

uri = "bolt+s://localhost:7687"
driver = GraphDatabase.driver(uri, auth=("movies", "movies"))


def get_actors(tx, movieTitle):
    """
    In Python, Cypher parameters are passed as named parameters to the tx.run method.
    In this example, title has been passed as a named parameter.
    """
    result = tx.run(
    """
    MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
    WHERE m.title = $title
    RETURN p
    """, title=movieTitle)

    return [ record["p"] for record in result ]


with driver.session() as session:
    result = session.read_transaction(get_actors, movieTitle="Toy Story")


driver.close()