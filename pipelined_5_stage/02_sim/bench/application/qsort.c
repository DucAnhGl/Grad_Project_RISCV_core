/*****************************************************************************/
/**** SimCore/RISC-V since 2018-07-05                ArchLab. TokyoTech   ****/
/*****************************************************************************/

#include "main.h"

int random_1_to_1000()
{
    static unsigned int x = 2463534242U;
    x ^= (x << 13);
    x ^= (x >> 17);
    x ^= (x << 5);
    return (x >> 10) % 1000 + 1;
}

void qsort (int a[], int first, int last)
{
    int i,j;
    int x,t;
    x = a[(first + last) / 2];
    i = first;
    j = last;
    for ( ; ; ) {
        while (a[i] < x) i++;
        while (x < a[j]) j--;
        if (i >= j) break;
        t = a[i];
        a[i] = a[j];
        a[j] = t;
        i++;
        j--;
    }
    if (first < i - 1) qsort(a, first, i - 1);
    if (j + 1 < last)  qsort(a, j + 1, last);
}
