/*****************************************************************************/
/**** SimCore/RISC-V since 2018-07-05                ArchLab. TokyoTech   ****/
/*****************************************************************************/

#include "main.h"
#include "simrv.h"

#define SORTN 10
#define FIBN  10
#define QUEEN 6
#define ACKN  3

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
    simrv_putc('\n');
    simrv_puts("The number of solutions = ");
    simrv_puth(num);  
    simrv_putc('\n');
    simrv_puts("----------------\n\n");

    simrv_puts("---- qsort  ----\n");
    int seq[SORTN];
    for (i = 0; i < SORTN; i++) seq[i] = random();
    qsort(seq, 0, SORTN - 1);
    
    simrv_puts("Sorted Seqence :\n");
    for (i = 0; i < SORTN; i++) {
        simrv_puth(seq[i]);
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
            simrv_putc('\n');
        }
    }
    simrv_puts("----------------\n\n");

    simrv_exit();
}
