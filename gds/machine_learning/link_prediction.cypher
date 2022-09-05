// Predicting Actor Relationships with Link Prediction

// We will create a  graph projection with just Actor nodes and ACTED_WITH relationships, like a 'co-acting'
// social network.When we use link prediction in this context, we will be training a model to predict
// which actors are most likely to be in the same movies together given other ACTED_WITH relationships
// already present in the graph.


// We will filter down to just big high grossing movies then create ACTED_WITH relationships between actors
// that were in the same movies together. There are a couple extra steps here to get the graph truly
// undirected as we need it.


//set a node label based on recent release and revenue conditions
MATCH (m:Movie)
WHERE m.year >= 1990 AND m.revenue >= 1000000
SET m:RecentBigMovie;
//native projection with reverse relationships
CALL gds.graph.project('proj',
  ['Actor','RecentBigMovie'],
  {
  	ACTED_IN:{type:'ACTED_IN'},
    HAS_ACTOR:{type:'ACTED_IN', orientation: 'REVERSE'}
  }
);
//collapse path utility for relationship aggregation - no weight property
CALL gds.alpha.collapsePath.mutate('proj',{
    relationshipTypes: ['ACTED_IN', 'HAS_ACTOR'],
    allowSelfLoops: false,
    mutateRelationshipType: 'ACTED_WITH'
});
//write relationships back to graph
CALL gds.graph.writeRelationship('proj', 'ACTED_WITH');
//drop duplicates
MATCH (a1:Actor)-[s:ACTED_WITH]->(a2)
WHERE id(a1) < id(a2)
DELETE s;
//clean up extra labels
MATCH (m:RecentBigMovie) REMOVE m:RecentBigMovie;

// ---------------------------------------------------

//project the graph
CALL gds.graph.drop('proj');
CALL gds.graph.project('proj', 'Actor', {ACTED_WITH:{orientation: 'UNDIRECTED'}});

// ----------------------------------------------------

// create the pipeline by running the following command:
CALL gds.beta.pipeline.linkPrediction.create('pipe');

// ----------------------------------------------------

// let’s use fastRP node embeddings with the logic that if two actors are close to each other in the
// ACTED_WITH network they are more likely to also play roles in the same movies. Degree centrality is also
// another potentially interesting feature, i.e. more prolific actors are more likely to be in the same
// movies with other actors.
CALL gds.beta.pipeline.linkPrediction.addNodeProperty('pipe', 'fastRP', {
    mutateProperty: 'embedding',
    embeddingDimension: 128,
    randomSeed: 7474
}) YIELD nodePropertySteps;

CALL gds.beta.pipeline.linkPrediction.addNodeProperty('pipe', 'degree', {
    mutateProperty: 'degree'
}) YIELD nodePropertySteps;


// ----------------------------------------------------

// adding link features. we use cosine distance and L2 for the FastRP embeddings, which are good measure
// of similarity/distance and hadamard for the degree centrality which are a good measure of total
// magnitude between the 2 nodes.

CALL gds.beta.pipeline.linkPrediction.addFeature('pipe', 'l2', {
  nodeProperties: ['embedding']
}) YIELD featureSteps;

CALL gds.beta.pipeline.linkPrediction.addFeature('pipe', 'cosine', {
  nodeProperties: ['embedding']
}) YIELD featureSteps;

CALL gds.beta.pipeline.linkPrediction.addFeature('pipe', 'hadamard', {
  nodeProperties: ['degree']
}) YIELD featureSteps;

// ----------------------------------------------------

// split the relationship into 20% test, 40% train, and 40% feature-input. This gives us a good balance between
// all the sets. We will also use 2.0 for the negative sampling ratio, giving us a sizable negative example
// for demonstration that won’t take too long to estimate.
CALL gds.beta.pipeline.linkPrediction.configureSplit('pipe', {
    testFraction: 0.2,
    trainFraction: 0.5,
    negativeSamplingRatio: 2.0
}) YIELD splitConfig;

// ----------------------------------------------------

// dd a few different logistic regressions here with different penalty hyperparameters.
CALL gds.beta.pipeline.linkPrediction.addLogisticRegression('pipe', {
    penalty: 0.001,
    patience: 2
}) YIELD parameterSpace;

CALL gds.beta.pipeline.linkPrediction.addLogisticRegression('pipe', {
    penalty: 1.0,
    patience: 2
}) YIELD parameterSpace;

// ----------------------------------------------------

// The following command will train the pipeline.

CALL gds.beta.pipeline.linkPrediction.train('proj', {
    pipeline: 'pipe',
    modelName: 'lp-pipeline-model',
    randomSeed: 7474 //usually a good idea to set a random seed for reproducibility.
}) YIELD modelInfo
RETURN
modelInfo.bestParameters AS winningModel,
modelInfo.metrics.AUCPR.train.avg AS avgTrainScore,
modelInfo.metrics.AUCPR.outerTrain AS outerTrainScore,
modelInfo.metrics.AUCPR.test AS testScore

// ----------------------------------------------------

// prediction in  streaming mode
CALL gds.beta.pipeline.linkPrediction.predict.stream('proj', {
  modelName: 'lp-pipeline-model',
  sampleRate:0.1,
  topK:1,
  randomSeed: 7474,
  concurrency: 1
})
 YIELD node1, node2, probability
 RETURN gds.util.asNode(node1).name AS actor1, gds.util.asNode(node2).name AS actor2, probability
 ORDER BY probability DESC, actor1

// ----------------------------------------------------