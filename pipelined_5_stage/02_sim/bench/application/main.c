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

void testhex(uint32_t num)  {
    *HEX0 = SEG7_ENCODINGS[num % 10];
    *HEX1 = SEG7_ENCODINGS[(num/10) % 10];
    *HEX2 = SEG7_ENCODINGS[(num/100) % 10];
    *HEX3 = SEG7_ENCODINGS[(num/1000) % 10];
    *HEX4 = SEG7_ENCODINGS[(num/10000) % 10];
    *HEX5 = SEG7_ENCODINGS[(num/100000) % 10];
}

// Simulation-friendly button check
uint8_t button_pressed() {
    return (*BTN & 0x01); // Immediate check without debounce
}

void exit_program () {
    while(1);
}

void run_selected(uint8_t selection) {
    int i, j;
    
    switch(selection) {

        case 0: { // QuickSort
            int seq[SORTN];
            for(i=0; i<SORTN; i++) seq[i] = random();
            qsort(seq, 0, SORTN-1);
            for(i=0; i<SORTN; i++) {
                testhex(seq[i]);
            }
            break;
        }
            
        case 1: { // Fibonacci
            for(i=1; i<=FIBN; i++) {
                testhex(fibonacci(i));
            }
            break;
        }
    }
}

int main(void) {
    int selection;
    // Continuous test mode for simulation
    while(1) {
        // Automatically cycle through all test cases
            //*LEDR = (1 << selection); // Show current test
            // Run test case
            run_selected(selection);
            *LEDR = (1 << selection);
            run_selected(selection);
            *LEDR = (1 << selection);

        exit_program();
    }
    
    return 0;
}

