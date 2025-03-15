/*****************************************************************************/
/**** SimCore/RISC-V since 2018-07-05                ArchLab. TokyoTech   ****/
/*****************************************************************************/

#include "main.h"

int acker (int x, int y)
{
    if (x == 0) return y + 1;
    if (y == 0) return acker(x - 1, 1);
    return acker(x - 1, acker(x, y - 1));
}
