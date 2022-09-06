## Graph Algorithms Fundamentals


GDS algorithms are classified into three tiers: alpha, beta, and production.

* **Production-quality**: Indicates that the algorithm has been tested in regard to stability and scalability. 
  Algorithms in this tier are prefixed with gds.<algorithm>.
* **Beta**: Indicates that the algorithm is a candidate for the production-quality tier. Algorithms in this tier 
  are prefixed with gds.beta.<algorithm>.
* **Alpha**: Indicates that the algorithm is experimental and might be changed or removed at any time. 
  Algorithms in this tier are prefixed with gds.alpha.<algorithm>.
  

GDS algorithms also have 4 executions modes which determine how the results of the algorithm are handled.

* **stream**: Returns the result of the algorithm as a stream of records.

* **stats**: Returns a single record of summary statistics, but does not write to the Neo4j database or modify any data.

* **mutate**: Writes the results of the algorithm to the in-memory graph projection and returns a single record of 
  summary statistics.

* **write**: Writes the results of the algorithm back the Neo4j database and returns a single record of 
  summary statistics.
  

As the size of data grows, a ubiquitous challenge for Data Science practitioners is figuring out how much 
memory is required to support their analytics and machine learning workflows. This can often require a lot of 
experimentation and trial and error. To circumvent this, GDS offers an estimation procedure which allows you 
to estimate the memory needed for using an algorithm on your data BEFORE actually executing it. To use the 
estimation procedure for different algorithms and execution modes you can simply append the command with .estimate.


All GDS algorithms follow the below syntax:

```
CALL gds[.<tier>].<algorithm>.<execution-mode>[.<estimate>](
	graphName: STRING,
	configuration: MAP
)
```

### Centrality 

Centrality algorithms are used to determine the importance of distinct nodes in a graph.

**Degree centrality** is one of the most ubiquitous and simple centrality algorithms. It counts the number of 
relationships a node has. In the GDS implementation, we specifically calculate out-degree centrality which 
is the count of outgoing relationships from a node. Below is an example of using degree centrality to count 
the number of movies each actor has acted in.

Another common centrality algorithm is **PageRank**. PageRank is a good algorithm for measuring the influence of nodes 
in a directed graph, particularly where the relationships imply some form of flow of movement such as in payment 
networks, supply chain and logistics, communications, routing, and graphs of website and links.

PageRank was originally developed by Google co-founders Larry Page and Sergey Brin at Stanford University in 
1996 as part of a research project about a new kind of search engine. It has since been used by Google Search to rank 
web pages in their search engine results.

In summary, PageRank estimates the importance of a node by counting the number of incoming relationships from 
neighboring nodes weighted by the importance and out-degree centrality of those neighbors. The underlying 
assumption is that more important nodes are likely to have proportionately more incoming relationships 
from other import nodes. 


Other GDS production tier centrality algorithms include:

**Betweenness Centrality**: Measures the extent to which a node stands between the other nodes in a graph. It is 
often used to find nodes that serve as a bridge from one part of a graph to another.

**Eigenvector Centrality**: Measures the transitive influence of nodes. Similar to PageRank, but works only on the 
largest eigenvector of the adjacency matrix so does not converge in the same way and tends to more strongly favor 
high degree nodes. It can be more appropriate in certain use cases, particularly those with undirected relationships.

**Article Rank**: A variant of PageRank which assumes that relationships originating from low-degree nodes have a 
higher influence than relationships from high-degree nodes.

## Pathfinding 

Path finding algorithms find the path between two or more nodes or evaluate the availability and quality of paths. 
The Neo4j GDS library includes the following path finding algorithms, grouped by quality tier:

|Production Quality|Beta|Alpha|
|:---:|:----:|:-----:|
| Delta-Stepping Single-Source Shortest Path, Dijkstra Source-Target Shortest Path,A* Shortest Path, Yen’s Shortest Path, Breadth First Search, Depth First Search | Random Walk|Minimum Weight Spanning Tree, All Pairs Shortes Path|

A common, industry standard, path finding algorithm is Dijkstra. It computes the shortest path 
between a source and a target node. Like many other path finding algorithms in GDS, Dijkstra supports 
weighted relationships to account for distance or another cost property when comparing paths.

An extension of Dijkstra that uses a heuristic function to speed up computation is A* Shortest Path.
Yen’s Algorithm Shortest Path allows you to find multiple, the top k, shortest paths. 
To compute all paths from a source node to all reachable nodes, Dijkstra Single-Source algorithm can be used.

Delta-Stepping Single-Source Shortest Path, parallelizes shortest path computation and computes faster than Dijkstra 
single-source shortest Path. However, it uses more memory.


## Node Embeddings


The goal of node embedding is to compute low-dimensional vector representations of nodes such that similarity 
between vectors (eg. dot product) approximates similarity between nodes in the original graph. These vectors, 
also called embeddings, can be extremely useful for exploratory data analysis, similarity measurements, and 
machine learning.

Nodes that are close together in the graph end up being close together in the 2-dimensional embedding space. 
The embedding takes the structure from the graph, the n-dimensional adjacency matrix, and approximates it in 
2-dimensional vectors for each node. The embedding vectors are much more efficient to use for downstream process 
due to significantly reduced dimensionality. They could be used for cluster analysis for example, or as features to 
train a node classification or link prediction model.

The Neo4j Graph Data Science library contains the following node embedding algorithms: 
FastRP (Production-quality) and GraphSAGE, Node2Vec (Beta)

Fast Random Projection(FastRP) leverages probabilistic sampling techniques to generate sparse representations 
of the graph allowing for extremely fast calculation of embedding vectors that are comparative in quality to 
those produced with traditional random walk and neural net techniques such as Node2vec and GraphSage. This 
makes FastRP a great choice for getting started with exploring embedding on your graph in GDS.

Node2Vec is a node embedding algorithm that computes a vector representation of a node based on random walks 
in the graph. The neighborhood is sampled through random walks. Using a number of random neighborhood 
samples, the algorithm trains a single hidden layer neural network. The neural network is trained to 
predict the likelihood that a node will occur in a walk based on the occurrence of another node.

GraphSAGE is using node feature information to generate node embeddings on unseen nodes or graphs. Instead of 
training individual embeddings for each node, the algorithm learns a function that generates embeddings by 
sampling and aggregating features from a node’s local neighborhood.

Node embedding vectors don’t offer insights by themselves, they are created to enable or scale other analytics. 
Common workflows include:

* **Exploratory Data Analysis (EDA)** such as visualizing the embeddings in a TSNE plot to better understand the graph 
  structure and potential clusters of nodes
* **Similarity Measurements**: Node embedding allows you to scale similarity inferences in large graphs using K Nearest 
  Neighbor (KNN) or other techniques. This can be useful for scaling memory based recommendation systems, such as 
  variations of collaborative filtering. It can also be used for semi-supervised techniques in areas like fraud 
  detection, where, for example, we may want to generate leads that are similar to a group of known fraudulent entities.
* **Features for Machine Learning**: Node embedding vectors naturally plug in as features for a variety of machine
  learning problems. For example, in a graph of user purchases for on online retailer, we could use embeddings to 
  train a machine learning model to predict what products a user may be interested in buying next.

## Similarity 

Similarity algorithms, as the name implies, are used to infer similarity between pairs of nodes. In GDS these 
algorithms run over the graph projection in bulk. When similar node pairs are identified according to the user 
specified metric and threshold, a relationship with a similarity score property is drawn between the pair. 
Depending on which execution mode is used when running the algorithm, these similarity relationships can be streamed, 
mutated to the in-memory graph, or written back to the database.

GDS has two primary similarity algorithms:

* **Node Similarity**: Determines similarity between nodes based on the relative proportion of shared neighboring 
  nodes in the graph. Node Similarity is a good choice where explainability is important, and you can narrow down 
  the universe of comparisons to a subset of your data. Examples of narrowing down include focusing on just single 
  communities, newly added nodes, or nodes within a specific proximity to a subgraph of interest.

* **K-Nearest Neighbor (KNN)**: Determines similarity based off node properties. The GDS KNN implementation can scale
  well for global inference over large graphs when tuned appropriately. it can be used in conjunction with embeddings 
  and other graph algorithms to determine the similarity between nodes based on proximity in the graph, node 
  properties, community structure, importance/centrality, etc.
  

Both Node Similarity and KNN provide choices between different similarity metrics. Node Similarity has choices 
between jaccard and overlap similarity. KNN choice of metric is driven by the node property types. list of integers 
are subject to jaccard and overlap, list of floating point numbers to cosine similarity, pearson, and euclidean. 
Using different metrics will of course alter the similarity score and change the interpretation slightly. 

For similarity comparisons we may also want to control the number of results returned to only consider the most 
relevant node pairs. Both Node Similarity and KNN have a topK parameter to limit the number similarity comparisons 
returned per node. With node similarity there is also the capability to limit the results globally as opposed 
to just a per node basis.


## Community Detection 

Community detection algorithms are used to evaluate how groups of nodes may be clustered or partitioned in the graph.
Much of the community detection functionality in GDS is focused on distinguishing and assigning ids to these node groups 
for downstream analytics, visualization, or other processing.

Common use cases of community detection include:

* Fraud detection: Finding fraud rings by identifying accounts that have frequent suspicious transactions and/or 
* share identifiers between one another.
* Customer 360: Disambiguating multiple records and interactions into a single customer profile so an organization has 
* an aggregated source of truth for each customer.
* Market segmentation: dividing a target market into approachable subgroups based on priorities, behaviors, interests, 
* and other criteria.

A common community detection algorithm is Louvain. Louvain maximizes a modularity score for each community, where the 
modularity quantifies the quality of an assignment of nodes to communities. This means evaluating how much more densely 
connected the nodes within a community are, compared to how connected they would be in a random network.
Louvain optimizes this modularity with a hierarchical clustering approach that recursively merges communities together. 
There are multiple parameters that can be used to tune Louvain to control its performance and the number and size of 
communities produced. This includes the maximum number of iterations and hierarchical levels to use as well as the 
tolerance parameter for assessing convergence/stopping conditions.
An additional important consideration is that Louvain is a stochastic algorithm. As such, the community assignments 
may change a bit when re-run. When the graph does not have a naturally well-defined community structure the changes 
between runs can become more significant. Louvain includes a seedProperty parameter which can be used to assign initial
community ids and help with consistency between runs. Also, if consistency is important for your use case, other 
community detection algorithms, such as Weakly Connected Components (WCC), take a more deterministic partitioning
approach to assigning communities and thus will not change between runs.

Below are some other production tier community detection algorithms. 

1. **Label Propagation** Similar intent as Louvain. Fast algorithm that parallelizes well. Great for large graphs.
2. **Weakly Connected Components (WCC)** Partitions the graph into sets of connected nodes such that:
   * Every node is reachable from any other node in the same set
   * No path exists between nodes from different sets
3. **Triangle Count** Counts the number of triangles for each node. Can be used to detect the cohesiveness of communities and stability of the graph.
4. **Local Clustering Coefficient** Computes the local clustering coefficient for each node in the graph which is an indicator for how the node clusters with its neighbors.