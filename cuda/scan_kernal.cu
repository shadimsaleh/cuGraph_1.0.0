#include "mainPPS.hpp"

// grid config:
//   dim3 grid(gridSize-1); dim3 block(blockSize);

__global__ void scan_kernal(int *masterSeed, int *size, float *PRNG) {
	
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	
}
