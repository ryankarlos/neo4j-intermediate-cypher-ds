// For this example, we will train a model to predict which movies in the graph are comedies which
// we will define as any movie that has a Genre of "Comedy".


// we will assign a cls property which is 1 if the movie is a comedy and 0 otherwise.
MATCH(m:Movie)-[:IN_GENRE]->(g)
WITH m , collect(g.name) AS genres
SET m.cls = toInteger('Comedy' IN genres)
RETURN count(m), m.cls;


// filter the movies to only consider those released on or after 2010 as this type of data may drift
// overtime making data further in the past less relevant.
MATCH(m:Movie)
WHERE m.year >= 2010
    AND m.runtime IS NOT NULL
    AND m.imdbRating IS NOT NULL
SET m:TrainMovie
RETURN count(m)


//  project a graph using the TrainMovie node label. We will project mirroring natural and reverse relationships

CALL gds.graph.project('proj',
    {
        Actor:{},
        TrainMovie:{ properties: ['cls', 'imdbRating', 'runtime']}
    },
    {
        ACTED_IN:{},
        HAD_ACTOR:{type:'ACTED_IN', orientation:'REVERSE'}
    }
);

// use collapsePath to provide a monopartite projection which will make the graph easier to handle inside the pipeline
CALL gds.alpha.collapsePath.mutate('proj',
  {
    relationshipTypes: ['HAD_ACTOR', 'ACTED_IN'],
    allowSelfLoops: false,
    mutateRelationshipType: 'SHARES_ACTOR_WITH'
  }
) YIELD relationshipsWritten;


//  create the pipeline by running the following command
CALL gds.beta.pipeline.nodeClassification.create('pipe')

// generate FastRP embeddings which will encapsulate the locality of movie nodes in the graph
CALL gds.beta.pipeline.nodeClassification.addNodeProperty('pipe', 'fastRP', {
  embeddingDimension: 32,
  randomSeed: 7474,
  mutateProperty:'embedding'
})
YIELD name, nodePropertySteps;

// can add degree centrality which will measure the number of other movies that share actors.
CALL gds.beta.pipeline.nodeClassification.addNodeProperty('pipe', 'degree', {
  mutateProperty:'degree'
})
YIELD name, nodePropertySteps;

// scale the runtime property which is good practice for values like this one that are relatively high
// magnitude compared to the other properties.
CALL gds.beta.pipeline.nodeClassification.addNodeProperty('pipe', 'alpha.scaleProperties', {
  nodeProperties: ['runtime'],
    scaler: 'Log',
  mutateProperty:'logRuntime'
})
YIELD name, nodePropertySteps;

// configure the subset of node properties that we want to use as features for the model
CALL gds.beta.pipeline.nodeClassification.selectFeatures(
    'pipe',
    ['imdbRating', 'logRuntime', 'embedding', 'degree'])
YIELD name, featureProperties;


// We configure a testFraction which determines how to randomly split between test and training nodes. Since the
// pipeline uses a cross-validation strategy, we can also set the number of validation folds we want here.
CALL gds.beta.pipeline.nodeClassification.configureSplit('pipe', {
 testFraction: 0.2,
  validationFolds: 5
})
YIELD splitConfig;

// we will just add a few different logistic regressions here with different penalty hyperparameters.

CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('pipe', {penalty: 0.0})
YIELD parameterSpace;

CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('pipe', {penalty: 0.1})
YIELD parameterSpace;


CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('pipe', {penalty: 1.0})
YIELD parameterSpace;

// The following command will train the pipeline. This command should output training scores according to metric.
// In this case we will get an accuracy of ~70%. Certainly a lot of room for improvement given the class balance.
// There are plenty of ways this problem could be remodeled with different features from the graph.

CALL gds.beta.pipeline.nodeClassification.train('proj', {
  pipeline: 'pipe',
  nodeLabels: ['TrainMovie'],
  modelName: 'nc-pipeline-model',
  targetProperty: 'cls',
  randomSeed: 7474,
  metrics: ['ACCURACY']
}) YIELD modelInfo
RETURN
  modelInfo.bestParameters AS winningModel,
  modelInfo.metrics.ACCURACY.train.avg AS avgTrainScore,
  modelInfo.metrics.ACCURACY.outerTrain AS outerTrainScore,
  modelInfo.metrics.ACCURACY.test AS testScore;


// The operation for predicting with the trained model and writing back to the graph has the following form

CALL gds.beta.pipeline.nodeClassification.predict.write(
  graphName: String,
  configuration: Map
)
YIELD
  preProcessingMillis: Integer,
  computeMillis: Integer,
  postProcessingMillis: Integer,
  writeMillis: Integer,
  nodePropertiesWritten: Integer,
  configuration: Map