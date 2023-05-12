#include <stdio.h>
#include <omp.h>
#define  SIZE 8192

int main(void) {
    int i,j;
    double dtime;
    static long A[SIZE][SIZE], b[SIZE],V[SIZE];
    for (i=0; i<SIZE; i++) {
        for (j=0; j<SIZE; j++) {
            A[i][j] = i+j;
        }
    }
    for (i=0; i<SIZE; i++) b[i] = i;

    dtime = -omp_get_wtime();
    #pragma omp parallel for private(j) //comment out for one thread
    for(i=0; i<SIZE; i++) {
        long sum = 0;
        for(j=0; j<SIZE; j++) {
            sum += A[i][j]*b[j];
        }
        V[i] += sum;
    }    
    dtime += omp_get_wtime();
    printf("The time taken for calculation is: %lf\n", dtime);

    return 0;
}
