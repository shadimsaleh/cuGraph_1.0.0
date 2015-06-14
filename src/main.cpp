#include "Graph.h"
#include "GraphDraw.h"
#include "Editor.h"
#include <QApplication>
#include <iostream>
#include "gstream.h"
#include "dataTypes.h"

using namespace std;
using namespace cuGraph;

int main(int argc, char** argv) {
    Graph g1;
    g1.setType(UN_DIRECTED, SELF_LOOP);
    g1.setNumberOfVertices(10);
    g1.fillByBaselineER(100, 0.5);

    cout << sizeof(long long int) << endl;

//    GraphDraw draw(argc, argv);
//    draw.setGraph(g3);
//    draw.randomPositions();
//    draw.run();

    ogstream gos;
    gos.open("src/gmls/test.txt");
    gos << g1;
    gos.close();

    igstream gis;
    gis.open("src/gmls/test.txt");
    Graph g2;
    g2.setType(UN_DIRECTED, SELF_LOOP);
    g2.setNumberOfVertices(10);
    gis >> g2;
    cout << g2.isEmpty() << endl;
    gis.close();

}









