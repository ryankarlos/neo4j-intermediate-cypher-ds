
GDS focuses on offering managed pipelines for end-to-end ML workflows. Data selection, feature engineering, data 
splitting, hyperparameter configuration, and training steps are coupled together within the pipeline object to 
track the end-to-end steps needed.

There are currently two supported types of ML pipelines:

* Node Classification Pipelines: Supervised binary and multi-class classification for nodes
* Link Prediction Pipelines: Supervised prediction for whether a relationship or "link" should exist between 
  pairs of nodes

These pipelines have a train procedure that, once run, produces a trained model object. These trained model objects, 
in turn, have a predict procedure that can be used to produce predictions on the data. You can have multiple pipelines 
and model objects at once in GDS. Both pipelines and models have a catalog that allows you to manage them by name, 
similar to graphs in the graph catalog.

## Node Classification

At a high level, the workflow will look like the following for node classification, this will be the same for 
link prediction as well:

1. Project a graph and configure the pipeline. The configuration steps are as follows. 
   Technically they need not be configured in order, though it helps  to do so to make things easy to follow.

* Create the Pipeline: use the command `CALL gds.beta.pipeline.nodeClassification.create('pipe')`
* Add Node Properties: A node classification pipeline can execute one or several GDS algorithms in mutate mode that 
  create node properties in the projection.
* Select Node Properties as Features: configure the subset of node properties that we want to use as 
  features for the model
* Configure Node Splits: configure the data splitting strategy i.e a testFraction which determines how to randomly 
  split between test and training nodes. We can also set the number of validation folds we want here.
* Add Model Candidates: The final step to pipeline configuration is creating model candidates. The pipeline 
  is capable of running multiple models with different training methods and hyperparameter configurations. 
  The best performing model will be selected after the training step completes.
  

2. Execute the pipeline with a `CALL gds.beta.pipeline.nodeClassification.train()`. This process will do the 
following: 

* Apply node and relationship filters
* Execute the above pipeline configuration steps
* Train with cross-validation for all the candidate models
* Select the best candidate according to the metric parameter (.e.g accuracy, F1, precision/recall)
* Retrain the winning model on the entire training set and perform a final evaluation on the test set 
  according to the metric
* Register the winning model in the model catalog

3. Predict on a projected graph with the predict command `gds.beta.pipeline.nodeClassification.predict.write()`. 
   The predictions can then be written back to the database if desired using graph write operations. The
   operation also supports stream and mutate execution modes. You can use this to classify newly added nodes or
   nodes in other regions of the graph. 

## Link Prediction

GDS currently offers a binary classifier where the target is a 0-1 indicator, 0 for no link, 1 for a link. 
This type of link prediction works really well on an undirected graph where you are predicting one type of
relationship between nodes of a single label, such as for social network and entity resolution problems.

 Link prediction problems are, generally speaking, notorious for severe class imbalance and performance issues 
 when data sampling is not approached thoughtfully. The implementation in GDS has multiple mechanisms for 
 overcoming these issues. In summary, it boils down to sampling and weighting procedures along with choosing
 appropriate evaluation metrics. 
 
### Configure the pipeline 

The configuration steps are as follows. Technically they need not be configured in order, 
though it helps to do so to make things easy to follow.

* Create the Pipeline: create the pipeline by running `CALL gds.beta.pipeline.linkPrediction.create('pipe')`.
This stores the pipeline in the pipeline catalog.
* Add Node Properties: we can add node properties, just like we did with the node classification pipeline.
* Add Link Features: Next we will add link features. This step configures a symmetric function that takes the 
  properties from the node pair and computes features for the link prediction model. 
  The types of link feature functions you can use are covered in the link prediction pipelines documentation 
  [here](https://neo4j.com/docs/graph-data-science/current/machine-learning/linkprediction-pipelines/config/#linkprediction-adding-features).
* Configure Relationship Splits: sets the train/test/feature set proportions, the negative sampling ratio, 
  and the number of validations folds used in cross-validation. 
  In the context of link prediction, a negative example is any node pair without a link between it. These are 
  randomly sampled in the relationship splitting step.
* Add Model Candidates: Just like with node classification, the final step to pipeline configuration is creating model
  candidates. The pipeline is capable of running multiple models with different training methods and hyperparameter 
  configurations. The best performing model will be selected after the training step completes.

### Train and prediction

The following command will train the pipeline: `gds.beta.pipeline.linkPrediction.train`. This process will:

* Apply node and relationship filters
* Execute the above pipeline configuration steps
* Train with cross-validation for all the candidate models
* Select the best candidate according to the average precision-recall
* Retrain the winning model on the entire training set and do a final evaluation on the test with AUCPR
* Register the winning model in the model catalog

Once the pipeline is trained we can use it to predict new links in the graph. The pipe
re-applied to data with the same schema. We can use the `gds.beta.pipeline.linkPrediction.predict.stream` 
to stream the results to client.
This operation supports a mutate execution mode to save the predicted links in the graph projection. 
If you want to write back to the database you can use the mutate mode followed by the 
`gds.graph.writeRelationship` command
This predict operation also has various sampling parameters that can be leveraged to more efficiently 
evaluate the large number of possible node pairs. The procedure will only select node pairs that do not 
currently have a link between them. 