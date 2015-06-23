#include <cuda/Parallel_functions.h>
#include <iostream>

__global__ void random_number_generator_kernal(int masterSeed, int size, float *PRNG);
__global__ void skipValue_kernal(float *S, float *R, int B, float p);
__global__ void skipValuePre_kernal(float *S, float *R, int B, float p, int m, float *F);
__global__ void addEdges_kernal(bool *content, float *S, int V, int B, int *L, int last);
__global__ void generatePredicateList_kernel(float *PL, int *T, float *R, int *B, int *i, float *p);
__global__ void compact_kernel(int *T, float *S, float *PL, int *SC, int *B);
__global__ void addEdges_kernel2(bool *content, int *SC, int *V, int *B);

void initDevice(void) {
    cudaFree(0);
}

void parallel_PZER(bool *content, float p, int lambda, int V, int E) {
    // declerations:
    bool *d_content;
    float *d_R, *d_S;
    int *d_L, *h_L;

    int B, L = 0;
    int seed = time(0)-1000000000;
    double segma = sqrt(p * (1 - p) * E);

    if((int)(p * E + lambda * segma) < 1000000)
        B = (int)(p * E + lambda * segma);
    else
        B = 1000000;

    // allocation:
    h_L = new int[1];
    cudaMalloc((void**) &d_content, V * V * sizeof(bool)); 	// 100 MB
    cudaMalloc((void**) &d_R, B * sizeof(float)); 			// 4 MB
    cudaMalloc((void**) &d_S, B * sizeof(float));			// 4 MB
    cudaMalloc((void**) &d_L, sizeof(int));
    thrust::device_ptr<float> d = thrust::device_pointer_cast(d_S);

    // copy:
    cudaMemcpy(d_content, content, V * V * sizeof(bool), cudaMemcpyHostToDevice);

    // run kernals:
    while(L < E) {
        random_number_generator_kernal<<<1, pow(2, 10)>>>(seed, B, d_R);
        skipValue_kernal<<<32, pow(2, 10)>>>(d_S, d_R, B, p);
        thrust::inclusive_scan(d, d+B, d);
        addEdges_kernal<<<32, pow(2, 10)>>>(d_content, raw_pointer_cast(&d[0]), V, B, d_L, L);

        cudaMemcpy(h_L, d_L, sizeof(float), cudaMemcpyDeviceToHost);
        L = h_L[0];

        //std::cout << L << " " << last << std::endl;
    }

    cudaMemcpy(content, d_content, sizeof(bool) * V * V, cudaMemcpyDeviceToHost);

    // free:
    delete h_L;
    cudaFree(d_content);
    cudaFree(d_R);
    cudaFree(d_S);
    cudaFree(d_L);
}

void parallel_PPreZER(bool *content, float p, int lambda, int m, int V, int E) {
    // declerations:
    bool *d_content;
    float *d_R, *d_S, *h_F, *d_F;
    int *d_L, *h_L;

    int B, L = 0;
    int seed = time(0)-1000000000;
    double segma = sqrt(p * (1 - p) * E);

    if((int)(p * E + lambda * segma) < 1000000)
        B = (int)(p * E + lambda * segma);
    else
        B = 1000000;

    h_F = new float[m+1];
    for(int i = 0; i <= m; i++) {
        h_F[i] = 1 - pow(1-p, i+1);
    }

    // allocation:
    h_L = new int[1];
    cudaMalloc((void**) &d_L, sizeof(int));
    cudaMalloc((void**) &d_F, (m+1) * sizeof(float));
    cudaMalloc((void**) &d_content, V * V * sizeof(bool)); 	// 100 MB
    cudaMalloc((void**) &d_R, B * sizeof(float)); 			// 4 MB
    cudaMalloc((void**) &d_S, B * sizeof(float));			// 4 MB
    thrust::device_ptr<float> d = thrust::device_pointer_cast(d_S);

    // copy:
    cudaMemcpy(d_F, h_F, (m+1) * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_content, content, V * V * sizeof(bool), cudaMemcpyHostToDevice);

    // run kernals:
    while(L < E) {
        random_number_generator_kernal<<<1, pow(2, 10)>>>(seed, B, d_R);
        skipValuePre_kernal<<<32, pow(2, 10)>>>(d_S, d_R, B, p, m, d_F);
        thrust::inclusive_scan(d, d+B, d);
        addEdges_kernal<<<32, pow(2, 10)>>>(d_content, raw_pointer_cast(&d[0]), V, B, d_L, L);

        cudaMemcpy(h_L, d_L, sizeof(float), cudaMemcpyDeviceToHost);
        L = h_L[0];

        //std::cout << h_last[0] << std::endl;
    }

    cudaMemcpy(content, d_content, sizeof(bool) * V * V, cudaMemcpyDeviceToHost);

    // free:
    delete h_L;
    delete h_F;
    cudaFree(d_L);
    cudaFree(d_content);
    cudaFree(d_R);
    cudaFree(d_S);
    cudaFree(d_F);
}

/*
void parallel_PER(bool *content, float p, int V, int E) {

    // declerations:
    bool *d_content;
    float *d_R, *d_S, *d_p, *h_p, *d_PL;
    int *d_seed, *h_seed, *d_B, *h_B, *d_V, *h_V, *d_i, *h_i, *d_T, *d_SC;

    int B = 10000000;
    int seed = time(0)-1000000000;
    int iter = E / B;

    // allocation:
    h_p = new float[1];
    h_seed = new int[1];
    h_V = new int[1];
    h_B = new int[1];
    h_i = new int[1];
    cudaMalloc((void**) &d_p, sizeof(float));
    cudaMalloc((void**) &d_seed, sizeof(int));
    cudaMalloc((void**) &d_V, sizeof(int));
    cudaMalloc((void**) &d_B, sizeof(int));
    cudaMalloc((void**) &d_i, sizeof(int));
    cudaMalloc((void**) &d_content, V * V * sizeof(bool)); 	// 100 MB
    cudaMalloc((void**) &d_R, B * sizeof(float)); 			// 8 MB
    cudaMalloc((void**) &d_S, B * sizeof(float));			// 8 MB
    cudaMalloc((void**) &d_PL, B * sizeof(float)); 			// 8 MB
    cudaMalloc((void**) &d_T, B * sizeof(int)); 			// 8 MB
    cudaMalloc((void**) &d_SC, B * sizeof(int)); 			// 8 MB

    // fill:
    h_p[0] = p;
    h_seed[0] = seed;
    h_V[0] = V;
    h_B[0] = B;

    // copy:
    cudaMemcpy(d_p, h_p, sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_seed, h_seed, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_V, h_V, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_content, content, V * V * sizeof(bool), cudaMemcpyHostToDevice);

    srand(time(0));

    // run kernals:
    for(int i = 0; i < iter; i++) {
        h_i[0] = i;
        cudaMemcpy(d_i, h_i, sizeof(int), cudaMemcpyHostToDevice);

        random_number_generator_kernal	<<<1 , pow(2, 10)>>>	(d_seed, d_B, d_R);
        generatePredicateList_kernel	<<<32, pow(2, 10)>>>	(d_PL, d_T, d_R, d_B, d_i, d_p);
        preallocBlockSums(B);
        prescanArray(d_S, d_PL, B);
        compact_kernel					<<<32, pow(2, 10)>>>	(d_T, d_S, d_PL, d_SC, d_B);
        addEdges_kernel2				<<<32, pow(2, 10)>>>	(d_content, d_SC, d_V, d_B);
    }

    cudaMemcpy(content, d_content, sizeof(bool) * V * V, cudaMemcpyDeviceToHost);

    // free:
    delete h_p;
    delete h_seed;
    delete h_B;
    delete h_V;
    delete h_i;
    cudaFree(d_p);
    cudaFree(d_seed);
    cudaFree(d_B);
    cudaFree(d_V);
    cudaFree(d_i);
    cudaFree(d_content);
    cudaFree(d_R);
    cudaFree(d_S);
    deallocBlockSums();
    cudaFree(d_SC);
    cudaFree(d_T);
    cudaFree(d_PL);
}

__global__ void generatePredicateList_kernel(float *PL, int *T, float *R, int *B, int *i, float *p) {

    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    while(tid < *B) {

        T[tid] = tid + *i * *B;

        if (R[tid] < *p)
            PL[tid] = 1;
        else
            PL[tid] = 0;

        tid += blockDim.x * gridDim.x;
    }
}

__global__ void compact_kernel(int *T, float *S, float *PL, int *SC, int *B) {

    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    while(tid < *B) {

        if((int)PL[tid] == 1)
            SC[(int)S[tid]] = T[tid];

        tid += blockDim.x * gridDim.x;
    }
}

__global__ void addEdges_kernel2(bool *content, int *SC, int *V, int *B) {

    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int v1, v2;

    while (tid < *B) {

        if(SC[tid] > 0) {
            v1 = (int)SC[tid] / *V;
            v2 = (int)SC[tid] % *V;
            content[v1 * *V + v2] = 1;
            content[v2 * *V + v1] = 1;
        }

        tid += blockDim.x * gridDim.x;
    }
}
*/
