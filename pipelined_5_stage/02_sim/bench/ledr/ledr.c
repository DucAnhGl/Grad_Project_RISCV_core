#include <stdio.h>

void test() {
    volatile int *result_mem = (volatile int *)0x20000;
    *result_mem = 0x55;
    volatile int *result_mem2 = (volatile int *)0x20004;
    *result_mem2 = 0x02;
}

void toggle() {
    volatile int *result_mem = (volatile int *)0x20000;
    *result_mem = 0xAA;
    volatile int *result_mem2 = (volatile int *)0x20004;
    *result_mem2 = 0x10;
}

void delay() {
    for (volatile int i = 0; i < 5000000; i++) { // 0.3s

    }
}

int main() {

    while(1) {
        test();
        delay();
        toggle();
        delay();
    }

    return 0;
}
