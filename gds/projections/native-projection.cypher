// These examples use the Neo4j recommendations dataset

// Create a native graph projection representing Users rating
// Movies and ensure the RATED relationship is undirected.
// The returns a single value from the procedure call, relationshipCount,
// which is the total relationship count of the native projection.


CALL gds.graph.project(
  'user-rated-movie',
  ['User', 'Movie'],
  {RATED:{orientation: 'UNDIRECTED'}}
)
YIELD relationshipCount


// Example of including multiple movie node properties and the rating
// relationship property. Note: existing native-proj need to be dropped

CALL gds.graph.drop('user-rated-movie', false);

CALL gds.graph.project(
    'user-rated-movie',
    ['User', 'Movie'],
    {RATED: {orientation: 'UNDIRECTED'}},
    {
        nodeProperties:{
            revenue: {defaultValue: 0}, // (1)
            budget: {defaultValue: 0},
            runtime: {defaultValue: 0}
        },
        relationshipProperties: ['rating'] // (3)
    }
)
