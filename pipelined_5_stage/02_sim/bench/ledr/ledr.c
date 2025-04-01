#include <stdio.h>

void test() {
    volatile int *result_mem = (volatile int *)0x20000;
    *result_mem = 255;
}

void toggle() {
    volatile int *result_mem2 = (volatile int *)0x20000;
    *result_mem2 = 0;
}

void delay() {
    for (volatile int i = 0; i < 5000000; i++) {

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
