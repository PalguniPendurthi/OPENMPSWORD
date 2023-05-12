#include <stdio.h>
#include <omp.h>

#define ARRAY_SIZE 1000

int main() {
    int shared_var = 0;
    int array[ARRAY_SIZE];

    // Initialize the array
    for (int i = 0; i < ARRAY_SIZE; i++) {
        array[i] = i;
    }

    #pragma omp parallel for simd shared(shared_var)
    for (int i = 0; i < ARRAY_SIZE; i++) {
        shared_var += array[i];  // Data race occurs here
    }

    printf("Shared variable: %d\n", shared_var);

    return 0;
}
