#include <stdio.h>
#include <omp.h>

#define ARRAY_SIZE 1000

int main() {
    int array[ARRAY_SIZE];
    int sum = 0;

    // Initialize the array
    for (int i = 0; i < ARRAY_SIZE; i++) {
        array[i] = i;
    }

    #pragma omp target map(to: array[:ARRAY_SIZE]) map(from: sum)
    {
        // Perform computation on the target device
        #pragma omp parallel for reduction(+:sum)
        for (int i = 0; i < ARRAY_SIZE; i++) {
            sum += array[i];
        }
    }

    printf("Sum: %d\n", sum);

    return 0;
}
