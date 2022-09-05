
// determine similarity between the actors and directors based on movies they have been involved with.

CALL gds.graph.project('proj', ['Movie', 'Person'], {
    ACTED_IN:{orientation:'UNDIRECTED'},
    DIRECTED:{orientation:'UNDIRECTED'}
});


// run FastRP  in mutate mode so the embeddings will be saved in the projection.
CALL gds.fastRP.mutate('proj',  {
    embeddingDimension:64,
    randomSeed:7474,
    mutateProperty:'embedding'
})

// run similarity with default cosine metric.

CALL gds.knn.stream('proj', {nodeLabels:['Person'], nodeProperties:['embedding'], topK:1})
YIELD  node1, node2, similarity
RETURN gds.util.asNode(node1).name AS actorName1,
    gds.util.asNode(node2).name AS actorName2,
    similarity
LIMIT 10