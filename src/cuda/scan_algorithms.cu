#include "mainPPS.hpp"

__host__ void inclusive_scan_sum(int *array, int length) { // sum all with current element

	for(int i = 1; i < length; i++) {
		array[i] = array[i-1] + array[i];
	}
}

__host__ void exclusive_scan_sum(int *array, int length) { // sum all expect current element (identity)

	int point1, point2; // to do it with just one array
	point1 = array[0];
	
	for(int i = 2; i < length; i++) {
		point2 = array[i];
		array[i] = array[i-1] + point1;
		point1 = point2;
	}
	
	array[1] = array[0];
	array[0] = 0;
}

__host__ void printArray(int *array, int length) {
	
	for(int i = 0; i < length; i++) {
		cout << array[i] << " ";
	}
	cout << endl;
}