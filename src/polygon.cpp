#include "draw.h"
#include <iostream>
int main() {
	int a = 10;
	a = a+1;
	std::cout << a << std::endl;
	//draw::setwindowsize(1000, 100);
	draw::setrange(-1, 1);
	draw::setpenwidth(5);
	draw::point(0.4, 0.1);
	draw::line(0.2, 0.1, 0.1, 0.2);
	draw::circle(0.1, 0.2, .2);
	draw::setcolor(255, 0, 0);
	draw::text("hello!\nthis is a message.", 0.5, 0.5);
	draw::setfontsize(30);
	draw::setcolor(draw::BLUE);
	draw::text("wow", 0.5, 0.8);
	draw::save("polygon.png");
	return 0;
}