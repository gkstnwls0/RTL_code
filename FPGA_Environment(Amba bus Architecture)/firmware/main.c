/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "xil_io.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "xil_mmu.h"
#include "platform.h"

#define DDR4_BASE_ADDR 0x1000000000LL
#define AXI_BASE_ADDR 0x0080000000LL

int data_length = 8;
int burst_length = 8;


void Gen_w_transaction(uint64_t addr, uint32_t *data, int burst_length) {
    volatile uint32_t *dest = (volatile uint32_t *)addr;
    for (int i = 0; i < burst_length; i++) {
        dest[i] = data[i];
    }
}

void Gen_r_transaction(uint64_t addr, uint32_t *data, int burst_length) {
    volatile uint32_t *src = (volatile uint32_t *)addr;
    for (int i = 0; i < burst_length; i++) {
        data[i] = src[i];
    }
}


void dma_rw_test() {

    uint32_t ddr4_write_data[data_length];
    uint32_t ddr4_read_data[data_length];
    uint64_t ddr4_addr = DDR4_BASE_ADDR;
    int i;


    xil_printf("Starting DDR4 write and read test...\n\r");

    // Set up memory attributes for the DDR4 region
    Xil_SetTlbAttributes(DDR4_BASE_ADDR, NORM_NONCACHE);

    // Initialize write data
    for (i = 0; i < data_length; i++) {
        ddr4_write_data[i] = 0xAA000000 + i;
    }

    // Write data to DDR4
    Gen_w_transaction(ddr4_addr, ddr4_write_data, burst_length);
    xil_printf("Data written to DDR4\n\r");
    // Read data from DDR4
    Gen_r_transaction(ddr4_addr, ddr4_read_data, burst_length);
    xil_printf("Data read from DDR4\n\r");

    // Verify data
    for (i = 0; i < data_length; i++) {
        if (ddr4_write_data[i] != ddr4_read_data[i]) {
            xil_printf("index %d: written 0x%08x, read 0x%08x\n\r", i, ddr4_write_data[i], ddr4_read_data[i]);
        } else {
            xil_printf("Data match at index %d: 0x%08x\n\r", i, ddr4_read_data[i]);
        }
    }
}

void ip_test() {
    uint32_t test_ip_write_data[data_length];
    uint32_t test_ip_read_data[data_length];
    uint32_t axi_addr = AXI_BASE_ADDR;
    int i;

    xil_printf("Starting IP test...\n\r");

    Xil_SetTlbAttributes(DDR4_BASE_ADDR, NORM_NONCACHE);
    // Initialize write data
//         for (i = 0; i < 2; i++) {
//        	 test_ip_write_data[i] = 0xBB000000+1;
//         }
         test_ip_write_data[0] = 0xBB000000;
     // Write data to DDR4 in a single 4-word burst
     Gen_w_transaction(axi_addr, test_ip_write_data, 1);
     xil_printf("Sending Operation Command and Data to Test IP\n\r");


     // Read data from DDR4 in a single 4-word burst
     Gen_r_transaction(axi_addr, test_ip_read_data, 1);
     xil_printf("Reading Operation Result Status from Test IP\n\r");

     // Verify data
     for (i = 0; i < 1; i++) {
         if (test_ip_read_data[i] != 0x00000001) {
             xil_printf("fail / index %d: read 0x%08x\n\r", i, test_ip_read_data[i]);
         } else {
             xil_printf("success / index %d: 0x%08x\n\r", i, test_ip_read_data[i]);
         }
     }

     axi_addr = AXI_BASE_ADDR+0x00000010;
     test_ip_write_data[0] = 0xBB000001;

     // Write data to DDR4 in a single 4-word burst
     Gen_w_transaction(axi_addr, test_ip_write_data, 1);
    xil_printf("Sending Operation Command and Data to Test IP\n\r");


     // Read data from DDR4 in a single 4-word burst
     Gen_r_transaction(axi_addr, test_ip_read_data, 1);
     xil_printf("Reading Operation Result Status from Test IP\n\r");

     // Verify data
     for (i = 0; i < 1; i++) {
        if (test_ip_read_data[i] != 0x00000001) {
           xil_printf("fail / index %d: read 0x%08x\n\r", i, test_ip_read_data[i]);
        } else {
           xil_printf("success / index %d: 0x%08x\n\r", i, test_ip_read_data[i]);
        }
    }
}

void verify_data() {
    uint32_t ddr4_read_data[data_length];
    uint64_t ddr4_addr = DDR4_BASE_ADDR;
    int i;

     // Read data from DDR4
    Gen_r_transaction(ddr4_addr, ddr4_read_data, burst_length);
     xil_printf("result Data read from DDR4\n\r");

     // Verify data
    for (i = 0; i < data_length; i++) {
        xil_printf("Data ddr4_read_data at index %d: read 0x%08x\n\r", i, ddr4_read_data[i]);
   }
}

int main() {
    u32 input_key = 999;
    while(1) {
        xil_printf("    0:  DMA RW Test\n");
        xil_printf("    1:  ip_test\n");
        xil_printf("    2:  verify_data\n");
        xil_printf("Insert Any Key: ");
        scanf("%u", &input_key);
        xil_printf(" Key: %d\n", input_key);

        switch(input_key) {
            case 0:
                dma_rw_test();
                break;
            case 1:
                ip_test();
                break;
            case 2:
                verify_data();
                break;
            default:
                xil_printf("Invalid Key\n");
                break;
        }
    }

    return 0;
}

