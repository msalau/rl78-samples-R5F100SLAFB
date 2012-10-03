#include "QB-R5F100SL-TB.h"

__attribute__((interrupt))
void wdti_handler(void)
{
}

__attribute__((interrupt))
void it_handler(void)
{
    LED1 ^= 1;
    LED2 ^= 1;
}

void main(void)
{
    asm("di");
    /* Setup LEDs */
    LED1 = 1;
    LED2 = 0;
    LED1_PIN = 0;
    LED2_PIN = 0;
    /* Setup clocks */
    CMC.cmc = 0x11U;                                        /* Enable XT1, disable X1 */
    CSC.csc = 0x80U;                                        /* Start XT1 */
    CKC.ckc = 0x00U;
    /* Delay 1 second */
    register unsigned long int i;
    for (i = 0x000FFFFFUL; i; --i)
        asm("nop");
    OSMC.osmc = 0x80U;                                      /* Supply fsub to Interval Timer */
    /* Setup 12-bit interval timer */
    RTCEN = 1;                                              /* Enable 12-bit interval timer and RTC */
    ITMK = 1;                                               /* Disable IT interrupt */
    ITPR0 = 0;                                              /* Set interrupt priority - highest */
    ITPR1 = 0;
    ITMC.itmc = 0x8FFFU;                                    /* Set maximum period ~270ms and start timer */
    ITIF = 1;                                               /* Set interrupt request flag */
    ITMK = 0;                                               /* Enable IT interrupt */
    asm ("ei");                                             /* Enable interrupts, immediate IT interrupt must happen */
    for(;;)
    {
        asm("stop");                                        /* Enter STOP mode, only interval timer stay running */
    }
}
