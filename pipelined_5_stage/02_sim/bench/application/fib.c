/*****************************************************************************/
/**** SimCore/RISC-V since 2018-07-05                ArchLab. TokyoTech   ****/
/*****************************************************************************/

#include "main.h"

int fibonacci (int n)
{
    if (n == 1) return 1;
    if (n == 2) return 1;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

