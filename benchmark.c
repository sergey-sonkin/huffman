#include <stdio.h>
#include <time.h>
#include <stdint.h>

// Original modulo implementation
static inline int subtract_mod9(int bit_count, int x) {
    bit_count = bit_count > 8 ? 8 : bit_count;
    bit_count = bit_count < 0 ? 0 : bit_count;
    return ((bit_count - x) % 9 + 9) % 9;
}

// Bitwise implementation
static inline int subtract_mod9_bitwise(int bit_count, int x) {
    bit_count &= 15;
    bit_count = bit_count > 8 ? 8 : bit_count;
    int result = bit_count - x;
    while (result < 0) result += 9;
    return result & 15;
}

// Simple lookup table implementation
static inline int subtract_mod9_lookup(int bit_count, int x) {
    static const int lookup[9][9] = {
        {0,8,7,6,5,4,3,2,1}, // bit_count = 0
        {1,0,8,7,6,5,4,3,2}, // bit_count = 1
        {2,1,0,8,7,6,5,4,3}, // bit_count = 2
        {3,2,1,0,8,7,6,5,4}, // bit_count = 3
        {4,3,2,1,0,8,7,6,5}, // bit_count = 4
        {5,4,3,2,1,0,8,7,6}, // bit_count = 5
        {6,5,4,3,2,1,0,8,7}, // bit_count = 6
        {7,6,5,4,3,2,1,0,8}, // bit_count = 7
        {8,7,6,5,4,3,2,1,0}  // bit_count = 8
    };
    return lookup[bit_count][x];
}

// New simplified version for when both numbers are 0-8
static inline int subtract_mod9_simple(int bit_count, int x) {
    int result = bit_count - x;
    return result < 0 ? result + 9 : result;
}

// Function to verify implementations give same results
void verify_implementations() {
    for (int bit_count = 0; bit_count <= 8; bit_count++) {
        for (int x = 0; x <= 8; x++) {
            int result1 = subtract_mod9(bit_count, x);
            int result2 = subtract_mod9_bitwise(bit_count, x);
            int result3 = subtract_mod9_lookup(bit_count, x);
            int result4 = subtract_mod9_simple(bit_count, x);
            
            if (result1 != result2 || result1 != result3 || result1 != result4) {
                printf("Mismatch found! bit_count=%d, x=%d: mod=%d, bitwise=%d, lookup=%d, simple=%d\n",
                       bit_count, x, result1, result2, result3, result4);
            }
        }
    }
}

// Benchmark function
void benchmark(const char* name, int (*func)(int, int), int iterations) {
    clock_t start = clock();
    volatile int sum = 0;  // volatile to prevent optimization
    
    // Run the benchmark
    for (int i = 0; i < iterations; i++) {
        for (int bit_count = 0; bit_count <= 8; bit_count++) {
            for (int x = 0; x <= 8; x++) {
                sum += func(bit_count, x);
            }
        }
    }
    
    clock_t end = clock();
    double cpu_time = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("%s: %.6f seconds (sum=%d)\n", name, cpu_time, sum);
}

int main() {
    printf("Verifying implementations...\n");
    verify_implementations();
    
    printf("\nRunning benchmarks...\n");
    const int iterations = 1000000;
    
    benchmark("Modulo", subtract_mod9, iterations);
    benchmark("Bitwise", subtract_mod9_bitwise, iterations);
    benchmark("Lookup", subtract_mod9_lookup, iterations);
    benchmark("Simple", subtract_mod9_simple, iterations);
    
    return 0;
}