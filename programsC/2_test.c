#include <stdio.h>

void test() {
    volatile int *result_mem = (volatile int *)0x3000;
    *result_mem = 255;
}

int main() {

    test();
    return 0;
}
