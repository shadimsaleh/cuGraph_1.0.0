#include "Graph.h"
#include "GraphDraw.h"
#include "Editor.h"
#include <QApplication>
#include <iostream>
#include "graphStream.h"

using namespace std;
using namespace cuGraph;

int main(int argc, char** argv) {
    Graph g1(10);
    g1.fillByBaselineER(100, 0.5);

    Graph *g3;
    g3 = &g1;

    int a = 10;
    a = a+1;
    cout << a << endl;

    g1.writeText("src/texts/g1_10_100_0.5");
    Graph g2(10);
    //g2.readText("src/texts/g1_10_100_0.5");
    //g2.writeText("src/texts/g1_10_100_0.5_2");

    //g1.writeGML("src/texts/gmelo.gml");

    GraphDraw draw(argc, argv);
    draw.setGraph(g3);
    draw.randomPositions();
    draw.exec();

    GraphIO gio("src/gmls/gmleo");
    gio << g1;
}









