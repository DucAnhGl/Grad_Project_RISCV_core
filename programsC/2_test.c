#include <stdio.h>

void test() {
    volatile int *result_mem = (volatile int *)0x20000;
    *result_mem = 255;
}

int main() {

    test();
    while(1);
    return 0;
}
