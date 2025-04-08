#include <stdio.h>

void test() {
    volatile int *result_mem = (volatile int *)0x20000;
    *result_mem = 0x55;
}

void toggle() {
    volatile int *result_mem2 = (volatile int *)0x20000;
    *result_mem2 = 0xAA;
}

void delay() {
    for (volatile int i = 0; i < N; i++) {

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
