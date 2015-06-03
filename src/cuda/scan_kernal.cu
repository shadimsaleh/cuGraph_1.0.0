#include "mainPPS.hpp"

// grid config:
//   dim3 grid(1); dim3 block(1024);

__global__ void cuScan(int *g_odata, int *g_idata, int n) {
	int thid = threadIdx.x;
	int offset = 1;
	
	for (int d = n>>1; d > 0; d >>= 1) { // build sum in place up the tree 
		__syncthreads();
		if (thid < d) {
			int ai = offset*(2*thid+1)-1;
			int bi = offset*(2*thid+2)-1;
			g_idata[bi] += g_idata[ai];
		}
		offset *= 2;
	}
	
	if (thid == 0) { g_idata[n - 1] = 0; } // clear the last element
	
	for (int d = 1; d < n; d *= 2) { // traverse down tree & build scan
		offset >>= 1;
		__syncthreads();
		if (thid < d) {
			int ai = offset*(2*thid+1)-1;
			int bi = offset*(2*thid+2)-1;
			int t = g_idata[ai];
			g_idata[ai] = g_idata[bi];
			g_idata[bi] += t;
		}
	}
	__syncthreads();
	g_odata[2*thid] = g_idata[2*thid]; // write results to device memory
	g_odata[2*thid+1] = g_idata[2*thid+1];
} 



