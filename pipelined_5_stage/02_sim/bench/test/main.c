/*****************************************************************************/
/**** SimCore/RISC-V since 2018-07-05                ArchLab. TokyoTech   ****/
/*****************************************************************************/
volatile int *result_mem = (volatile int *)0x20000;

#include "main.h"
#include "simrv.h"
#include <stdint.h>

#define HEX_BASE        0x20004

#define SORTN 10
#define FIBN  10
#define QUEEN 6
#define ACKN  3

const uint8_t SEG7_ENCODINGS[] = {
    0x40, 0x79, 0x24, 0x30,
    0x19, 0x12, 0x02, 0x78,
    0x00, 0x10, 0x08, 0x03,
    0x46, 0x21, 0x06, 0x0E
};

volatile uint8_t  *HEX0 = (volatile uint8_t *)(HEX_BASE + 0);
volatile uint8_t  *HEX1 = (volatile uint8_t *)(HEX_BASE + 1);
volatile uint8_t  *HEX2 = (volatile uint8_t *)(HEX_BASE + 2);
volatile uint8_t  *HEX3 = (volatile uint8_t *)(HEX_BASE + 3);
volatile uint8_t  *HEX4 = (volatile uint8_t *)(HEX_BASE + 4);
volatile uint8_t  *HEX5 = (volatile uint8_t *)(HEX_BASE + 5);

void testhex(uint32_t num)  {
    *HEX0 = SEG7_ENCODINGS[num % 10];
    *HEX1 = SEG7_ENCODINGS[(num/10) % 10];
    *HEX2 = SEG7_ENCODINGS[(num/100) % 10];
    *HEX3 = SEG7_ENCODINGS[(num/1000) % 10];
    *HEX4 = SEG7_ENCODINGS[(num/10000) % 10];
    *HEX5 = SEG7_ENCODINGS[(num/100000) % 10];
}


int main(void)
{
    int i, j;

    simrv_puts("---- nqueen ----\n");
    int a[QUEEN];
    int b[2 * QUEEN - 1];
    int c[2 * QUEEN - 1];
    int x[QUEEN];
    for (i = 0; i < QUEEN; i++)         a[i] = 1; 
    for (i = 0; i < 2 * QUEEN - 1; i++) b[i] = 1;      
    for (i = 0; i < 2 * QUEEN - 1; i++) c[i] = 1;   
    for (i = 0; i < QUEEN; i++)         x[i] = 0;
    int num = nqueen (0, a, b, c, x, QUEEN);
    simrv_puts("Nqueen :\n");
    simrv_puts("N = "); 
    simrv_puth(QUEEN);
    testhex(QUEEN); 
    simrv_putc('\n');
    simrv_puts("The number of solutions = ");
    simrv_puth(num); 
    testhex(num); 
    simrv_putc('\n');
    simrv_puts("----------------\n\n");

    simrv_puts("---- qsort  ----\n");
    int seq[SORTN];
    for (i = 0; i < SORTN; i++) seq[i] = random();
    qsort(seq, 0, SORTN - 1);
    
    simrv_puts("Sorted Seqence :\n");
    for (i = 0; i < SORTN; i++) {
        simrv_puth(seq[i]);
        testhex(seq[i]);
        simrv_putc('\n');
    }
    simrv_puts("----------------\n\n");

    simrv_puts("---- fib    ----\n");
    simrv_puts("Fibonacci Seqence :\n");
    for (i = 1; i <= FIBN; i++) {
        int val = fibonacci(i);
        simrv_puth(i);
        simrv_puts(": ");
        simrv_puth(val);
        testhex(val);
        simrv_putc('\n');
    }
    simrv_puts("----------------\n\n");

    simrv_puts("---- acker  ----\n");
    for (i = 0; i < ACKN; i++) {
        for (j = 0; j < ACKN; j++) {
            int val = acker(i, j);
            simrv_puts("acker(");
            simrv_puth(i);
            simrv_putc(',');
            simrv_puth(j);
            simrv_puts(") = ");
            simrv_puth(val);
            testhex(val);
            simrv_putc('\n');
        }
    }
    simrv_puts("----------------\n\n");

    simrv_exit();
}
