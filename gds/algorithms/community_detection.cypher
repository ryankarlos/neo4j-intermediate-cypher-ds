
//  ----- running Louvain to understand communities of actors and directors in our movies recommendations graph.


// First create a graph projection with movies, actors, and directors. Project the relationships with an
// UNDIRECTED orientation as that works best with the Louvain algorithm.
CALL gds.graph.project('proj', ['Movie', 'Person'], {
    ACTED_IN:{orientation:'UNDIRECTED'},
    DIRECTED:{orientation:'UNDIRECTED'}
});


// Then we can run Louvain. Here we will run Louvain in mutate mode to save community Ids and return high level
// statistics on the community counts, distribution, modularity score, and information for how Louvain processed the graph.
CALL gds.louvain.mutate('proj', {mutateProperty:'communityId'})

// We can verify the communityId node properties in the projection with a stream operation.
CALL gds.graph.streamNodeProperty('proj','communityId', ['Person'])
YIELD nodeId, propertyValue
WITH gds.util.asNode(nodeId) AS n, propertyValue AS communityId
WHERE n:Person
RETURN n.name, communityId LIMIT 10