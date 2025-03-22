#include "simrv.h"

volatile int *TOHOST_ADDR = (int *)0x40008000;

void simrv_exit () {
    while(1);
}

void simrv_putc (char c) {
    *TOHOST_ADDR = CMD_PRINT_CHAR << 16 | c;
}

void simrv_puts (char *str) {
    for (char *c = str; *c != '\0'; c++) {
        simrv_putc(*c);
    }
}

int greet(int a, int b) {
    // Do something non-trivial so it isn't optimized away
    volatile int result = a + b;

    return result;
}

int fibonacci(int n) {
    if (n < 2) {
        return n;  // fib(0) = 0, fib(1) = 1
    }
    
    int prev = 0;
    int curr = 1;
    int next;
    
    for (int i = 2; i <= n; i++) {
        next = prev + curr;
        prev = curr;
        curr = next;
    }
    
    return curr;
}

int main(void) {
    static const char message[] = "Hello, rodata!";
    
    int a = 3;
    int b = 4;
    int result;
    int fib;
    // Call our function that has two int parameters
    int i = 0;
    while (i < 20) {
        result = greet(a + i, b + i);
        fib = fibonacci(a + i);
        *(volatile int *)0x20000 = result;
        *(volatile int *)0x20004 = fib;
        i++;
    }
    //simrv_puts("The number of solutions = ");
    simrv_exit();
    // Returning 0 will generate a 'ret' in main
    return 0;
}