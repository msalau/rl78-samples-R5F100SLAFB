#include "QB-R5F100SL-TB.h"

__attribute__((interrupt))
void wdti_handler(void)
{
}

void main(void)
{
    LED1_PIN = 0;
    LED2_PIN = 0;
    for(;;)
    {
        if (SW1)
        {
            LED1 = 1;
            LED2 = 0;
        }
        else
        {
            LED1 = 0;
            LED2 = 1;
        }
    }
}
