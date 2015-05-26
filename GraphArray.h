#ifndef GRAPHARRAY_H_
#define GRAPHARRAY_H_

class GraphArray {
	public:
		GraphArray();
		GraphArray(int numberOfVertices);
		virtual ~GraphArray();
		int getNumberOfVertices();
		int getNumberOfEdges();
		int *getContent();
		int getSize();
		void printGraphAsArray(void);
		void addEdge(int v1, int v2);
		void removeEdge(int v1, int v2);
		bool isDirectlyConnected(int v1, int v2);
		bool isConnected(int v1, int v2);
		bool isEmpty();
		bool isFullyConnected();
		void fillByBaselineER(int E, double p); // TODO: check p
		void fillByZER(int E, double p);
		void fillByPreLogZER(int E, double p);
		void fillByPreZER(int E, double p, int m);
		void clear();
	protected:
	private:
		int size;
		int *content;
		int numberOfVertices;
		int numberOfEdges;
		void checkVertixName(int vert);
		void checkEdgeRange(int edge);
};

#endif // GRAPHARRAY_H_
