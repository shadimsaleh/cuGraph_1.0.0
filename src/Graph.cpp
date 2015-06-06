#include <iostream>
#include <algorithm>
#include <cstdlib>
#include <ctime>
#include <cmath>

#include "Path.h"
#include "Graph.h"
#include "Exceptions.h"

using namespace std;

Graph::Graph() {}

Graph::Graph(int V) :numberOfVertices(V) {
	size = pow(numberOfVertices, 2);
	numberOfEdges = 0;
	content = new int[size];

	fill(content, content+size, 0);
}

Graph::~Graph() {
	delete content;
}

void Graph::clear() { // TODO: clear content instead
    for(int i = 0; i < numberOfVertices; i++) {
        for(int j = 0; j < numberOfVertices; j++) {
            removeEdge(i, j);
        }
    }
}

void Graph::addEdge(int v1, int v2) {
    if(isFullyConnected()) // TODO: method
//		throw new GraphEdgeOutOfBoundsException(size, edge); // TODO: change with other exception

    checkVertixName(v1);
    checkVertixName(v2);
    content[v1 * numberOfVertices + v2] = 1;
    content[v2 * numberOfVertices + v1] = 1;
    numberOfEdges++;
}
// acycle graph
void Graph::removeEdge(int v1, int v2) {
    if(isEmpty()) // TODO: method
//		throw new GraphEdgeOutOfBoundsException(size, edge); // TODO: change with other exception

    checkVertixName(v1);
    checkVertixName(v2);

    if(isDirectlyConnected(v1, v2)) {

        content[v1 * numberOfVertices + v2] = 0;
        content[v2 * numberOfVertices + v1] = 0;
        numberOfEdges--;
    }
}

void Graph::printGraphAsArray(void) {
    for(int i = 1; i <= size; i++) {
        cout << content[i-1] << " ";

        if (i % numberOfVertices == 0)
            cout << endl;
    }
}

bool Graph::isEmpty() { // from edge prespective not vertix (because vertices is constant (cuda))
    if(numberOfEdges == 0)
        return true;

    return false;
}

bool Graph::isConnected(int v1, int v2) {
    checkVertixName(v1);
    checkVertixName(v2);

    Path p(this, v1);
    return p.hasPathTo(v2);
}

bool Graph::isFullyConnected() {
    if(numberOfEdges == pow(numberOfVertices, 2))
        return true;

    return false;
}

bool Graph::isDirectlyConnected(int v1, int v2) {
    checkVertixName(v1);
    checkVertixName(v2);
    if (content[v1 * numberOfVertices + v2] && content[v2 * numberOfVertices + v1])
        return true;
    return false;
}

void Graph::fillByBaselineER(int E, double p) {// TODO: check p
	checkEdgeRange(E);
	srand(time(0));
	double theta;

	int v1, v2;
	for(int i = 0; i < E; i++) {
		theta = (double)rand() / RAND_MAX;

		if (theta < p) {
			v1 = i / numberOfVertices;
			v2 = i % numberOfVertices;
			addEdge(v1, v2);
		}
	}
}

void Graph::fillByZER(int E, double p) {
	checkEdgeRange(E);
	srand(time(0));
	double theta, logp;

	int v1, v2, k, i = -1;
	while (i < E) {
		theta = (double)rand() / RAND_MAX;
		logp = log10f(theta)/log10f(1-p);

		k = max(0, (int)ceil(logp) - 1);
		i += k + 1;

		if(i < E) { // equavelent to: Discard last edge, because i > E
			v1 = i / numberOfVertices;
			v2 = i % numberOfVertices;
			addEdge(v1, v2);
		}
	}
}

void Graph::fillByPreLogZER(int E, double p) {
	checkEdgeRange(E);
	srand(time(0));
	double *logp, c;

	c = log10f(1-p);

	for(int i = 0; i < RAND_MAX; i++) {
		logp[i] = log10f(i/ RAND_MAX);
	}

	int theta, v1, v2, k, i = -1;
	while (i < E) {
		theta = rand();

		k = max(0, (int)ceil(logp[theta] / c) - 1);
		i += k + 1;

		if(i < E) { // equavelent to: Discard last edge, because i > E
			v1 = i / numberOfVertices;
			v2 = i % numberOfVertices;
			addEdge(v1, v2);
		}
	}
}

void Graph::fillByPreZER(int E, double p, int m) {
	checkEdgeRange(E);
	srand(time(0));
	double theta, logp;
	double *F = new double[m+1];

	for(int i = 0; i <= m; i++) {
		F[i] = 1 - pow(1-p, i+1);
	}

	int v1, v2, k, j, i = -1;
	while(i < E) {
		theta = (double)rand() / RAND_MAX;

		j = 0;
		while(j <= m) {
			if(F[j] > theta) {
				k = j;
				break; // must break from j while loop not i while loop
			}
			j++;
		}

		// if could not find k from the upper loop
		if(j == m+1) { // rare to happen for large m value
			logp = log10f(1-theta)/log10f(1-p);
			k = max(0, (int)ceil(logp) - 1);
		}

		i += k + 1;

		if(i < E) { // equavelent to: Discard last edge, because i > E
			v1 = i / numberOfVertices;
			v2 = i % numberOfVertices;
			addEdge(v1, v2);
		}
	}
}

int Graph::getSize() {
    return size;
}

int *Graph::getContent() {
    return content;
}

int Graph::getNumberOfEdges() {
    return numberOfEdges;
}

int Graph::getNumberOfVertices() {
    return numberOfVertices;
}


void Graph::checkVertixName(int vert) {
    if (vert < 0 || vert >= numberOfVertices)
        throw new GraphVertexOutOfBoundsException(numberOfVertices, vert);
}

void Graph::checkEdgeRange(int edge) {
    //if (edge < 0 || edge > size)
        //throw new GraphEdgeOutOfBoundsException(size, edge);
}

