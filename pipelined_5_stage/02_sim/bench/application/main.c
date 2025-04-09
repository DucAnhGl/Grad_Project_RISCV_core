#include "main.h"
#include <stdint.h>

// Simulation-friendly hardware definitions
#define LEDR_BASE       0x20000
#define HEX_BASE        0x20004
#define SW_BASE         0x30000
#define BTN_BASE        0x30004

// Hardware registers (simulation view)
volatile uint16_t * LEDR = (volatile uint16_t *)LEDR_BASE;
volatile uint8_t  * HEX0 = (volatile uint8_t *)(HEX_BASE + 0);
volatile uint8_t  * HEX1 = (volatile uint8_t *)(HEX_BASE + 1);
volatile uint8_t  * HEX2 = (volatile uint8_t *)(HEX_BASE + 2);
volatile uint8_t  * HEX3 = (volatile uint8_t *)(HEX_BASE + 3);
volatile uint8_t  * HEX4 = (volatile uint8_t *)(HEX_BASE + 4);
volatile uint8_t  * HEX5 = (volatile uint8_t *)(HEX_BASE + 5);
volatile uint16_t * SW   = (volatile uint16_t *)SW_BASE;
volatile uint8_t  * BTN  = (volatile uint8_t *)BTN_BASE;

// 7-Segment encodings
const uint8_t SEG7_ENCODINGS[] = {
    0x40, 0x79, 0x24, 0x30,
    0x19, 0x12, 0x02, 0x78,
    0x00, 0x10, 0x08, 0x03,
    0x46, 0x21, 0x06, 0x0E
};

#define SORTN 10
#define FIBN  10


// Function prototypes
void testhex(uint32_t num);
void qsort(int arr[], int left, int right);
int fibonacci(int n);
int random();

void delay_ms(int ms) {
    for (int i = 0; i < ms; i++) {
        for (volatile int j = 0; j < 50000; j++) {
            // Each iteration ~1 clock cycle (depends on compiler optimization)
        }
    }
}

int debounce_button(uint8_t mask) {
    const int stable_count = 5;
    int count = 0;

    for (int i = 0; i < stable_count; i++) {
        if ((*BTN & mask) == 0) {  // Active-low press
            count++;
        }
        delay_ms(1);  // ~1 ms delay on 50 MHz clock
    }

    if (count == stable_count) {
        while ((*BTN & mask) == 0) {
            delay_ms(1);
        }
        return 1;
    }

    return 0;
}

int no_debounce_button(uint8_t mask) {
    if ((*BTN & mask) == 0) {
        while ((*BTN & mask) == 0);
        return 1;
    }
    return 0;
}

void testhex(uint32_t num)  {
    *HEX0 = SEG7_ENCODINGS[num % 10];
    *HEX1 = SEG7_ENCODINGS[(num/10) % 10];
    *HEX2 = SEG7_ENCODINGS[(num/100) % 10];
    *HEX3 = SEG7_ENCODINGS[(num/1000) % 10];
    *HEX4 = SEG7_ENCODINGS[(num/10000) % 10];
    *HEX5 = SEG7_ENCODINGS[(num/100000) % 10];
}

void exit_program () {
    while(1);
}


int main(void) {
    int input_data = 10;           // Default
    int seq[100];
    uint8_t initialized = 0;

    while (1) {
        uint16_t switch_val = *SW;

        uint8_t selection = (switch_val >> 8) & 0x1;     // SW8
        uint8_t sw_input  = switch_val & 0xF;            // SW[3:0]

        if (debounce_button(0x02)) {
            input_data = (sw_input == 0) ? 10 : sw_input;
        }

        if (debounce_button(0x01)) {
            *LEDR = (1 << selection);

            if (selection == 0) {  // QuickSort Mode

                if (!initialized) {
                    for (int i = 0; i < input_data; i++) {
                        seq[i] = i;
                        testhex(seq[i]);
                        delay_ms(250);
                    }
                    initialized = 1;
                } else {
                    // Second press: Sort and display
                    qsort(seq, 0, input_data - 1);

                    for (int i = 0; i < input_data; i++) {
                        testhex(seq[i]);
                        delay_ms(250);
                    }

                    initialized = 0; 
                }

            } else { // Fibonacci Mode
                for (int i = 1; i <= input_data; i++) {
                    testhex(fibonacci(i));
                    delay_ms(250);
                }
            }
        }
    }

    return 0;
}
