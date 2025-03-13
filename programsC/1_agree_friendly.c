#include <stdio.h>

// Function to sum numbers from 1 to n
int sum_to_n(int n) {
    int sum = 0;
    int i;

    // Loop to sum numbers from 1 to n
    for (i = 1; i <= n; i++) {
        sum += i;
    }

    return sum;
}

int main() {
    int result;

    // Sum numbers from 1 to 5
    result = sum_to_n(5);

    // Store the result in memory at address 0x3000
    volatile int *result_mem = (volatile int *)0x3000;
    *result_mem = result;

    // Now load the result from memory into register x10
    // Simulate loading it into register x10
    int x10 = *result_mem;  // This step is just for simulation purposes in C

    // Since there's no output available, we'll just keep the result in x10
    // In actual hardware, you would use x10 for further processing

    // Terminate the program
    return 0;
}
