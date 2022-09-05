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
