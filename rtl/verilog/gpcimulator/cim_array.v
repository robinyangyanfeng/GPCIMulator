`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/07 17:41:16
// Design Name: 
// Module Name: cim_array
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cim_array(
    
    // normal sram interface
    input   [AWIDTH-1:0]    addr,
    input   [DWIDTH-1:0]    din,
    output  [DWIDTH-1:0]    dout,
    input                   we,         // write enable, high active
    input                   oe,         // read enable, high active
 //   input                   cs,         // chip select

    //  control signals
    input                   cme,         // CIM enable, high active
    input                   func

    );

    // Define the address map first and change all of the following parameter according

    parameter   DWIDTH = 32;    // unit : bit
    parameter   AWIDTH = 12;    // unit : bit

    //-----------Generated Parameters----------------//
    parameter   RAM_DEPTH = 1 << AWIDTH;

    //-----------Generated CIM Bitcell---------------//
    wire [3:0]      cmIn_00,    cmIn_01,    cmIn_02,    cmIn_03,
                    cmIn_04,    cmIn_05,    cmIn_06,    cmIn_07,
                    cmIn_08,    cmIn_09,    cmIn_10,    cmIn_11,
                    cmIn_12,    cmIn_13,    cmIn_14,    cmIn_15;

    input [3:0] func;

    wire    [3:0]   cmOut_00,   cmOut_01,   cmOut_02,   cmOut_03,
                    cmOut_04,   cmOut_05,   cmOut_06,   cmOut_07,
                    cmOut_08,   cmOut_09,   cmOut_10,   cmOut_11,
                    cmOut_12,   cmOut_13,   cmOut_14,   cmOut_15;

    //-------------Internal variables-----------------//

    reg [DWIDTH-1:0]    mem [0:RAM_DEPTH-1];

    //----------Code Start




endmodule
