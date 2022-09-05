// Below is an example of generating FastRP embeddings on person nodes in the movies
// graph based on the movies they acted in and/or directed.

CALL gds.graph.project('proj', ['Movie', 'Person'], {
    ACTED_IN:{orientation:'UNDIRECTED'},
    DIRECTED:{orientation:'UNDIRECTED'}
});

// We will run FastRP, with am embedding dimension of 64.
// We have the option of setting a randomSeed here as well to control consistency between runs.

CALL gds.fastRP.stream('proj',  {embeddingDimension:64, randomSeed:7474})
YIELD nodeId, embedding
WITH gds.util.asNode(nodeId) AS n, embedding
WHERE n:Person
RETURN id(n), n.name, embedding LIMIT 10