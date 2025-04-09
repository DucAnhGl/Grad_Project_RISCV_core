/*****************************************************************************/
/**** SimCore/RISC-V since 2018-07-05                ArchLab. TokyoTech   ****/
/*****************************************************************************/

#include "main.h"

int nqueen (int i, int a[], int b[], int c[], int x[], int N)
{
    int j;
    int ret = 0;
    for (j = 0; j < N; j++) {
        if (a[j] && b[i + j] && c[i - j + N - 1]) {
            x[i] = j;
            if (i < N - 1) {
                a[j] = b[i + j] = c[i - j + N - 1] = 0;
                ret += nqueen (i + 1, a, b, c, x, N);
                a[j] = b[i + j] = c[i - j + N - 1] = 1;
            } else {
                return 1;
            }
        }
    }
    return ret;
}
