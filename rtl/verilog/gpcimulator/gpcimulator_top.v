`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/30 22:23:33
// Design Name: 
// Module Name: gpcimulator
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


module gpcimulator(
    input           HCLK,
    input           HRESETn,
    input [31:0]    HADDR,
    input [1:0]     HTRANS,
    input           HWRITE,
    input [2:0]     HSIZE,
    input [2:0]     HBRUST,
    input [3:0]     HPROT,
    input [31:0]    HWDATA,
    input           HSELx,
    output [31:0]   HRDATA,
    output          HREDAY,
    output [1:0]    HRESP
    );

wire HCLK,HRESETn,HWRITE,HSELx,HREDAY;
wire [31:0] HADDR,HWDATA,HRDATA;
wire [1:0]  HTRANS,HRESP;
wire [2:0]  HSIZE,HBRUST;
wire [3:0]  HPROT;

wire [31:0] reg_addr_in,reg_addr_out,reg_data_in,reg_data_out;
wire [31:0] reg_cim_data_in,reg_cim_data_out,reg_cim_we;
wire reg_we,reg_re,reg_irq;

wire rc_irq_out;

wire cim_array_irq_out;

wire [31:0] cim_array_addr_in;

wire enable, we;

assign enable = (|reg_cim_data_in) & (~cim_array_irq_out);

    ahb_if u_ahb_if (   
    // AHB interface signals
    .HCLK       (HCLK   ),
    .HRESETn    (HRESETn),
    .HADDR      (HADDR  ),
    .HTRANS     (HTRANS ),
    .HWRITE     (HWRITE ),
    .HSIZE      (HSIZE  ),
    .HBRUST     (HBRUST ),
    .HPROT      (HPROT  ),
    .HWDATA     (HWDATA ),
    .HSELx      (HSELx  ),
    .HRDATA     (HRDATA ),
    .HREDAY     (HREDAY ),
    .HRESP      (HRESP  ),

    // Regs
    .addr_out   (reg_addr_in),
    .data_in    (reg_data_out),
    .data_out   (reg_data_in),
    .wr_enable  (reg_we  ),
    .irq_in     (reg_irq )

    );

    reg_set u_reg_set (
    
    // ahb if signals
    .sys_clk_in     (HCLK       ),
    .rst_n          (HRESETn    ),
    .addr_in        (reg_addr_in),
    .data_out       (reg_data_out),
    .reg_we         (reg_we     ),
    .reg_re         (reg_re     ),
    .irq_out        (reg_irq    ),

    // row_copy controller signals
    .addr_out       (reg_addr_out),
    .irq_in         (rc_irq_out),

    // cim array
    .cim_data_out   (reg_cim_data_out),
    .cim_data_in    (reg_cim_data_in ),
    .cim_we         (reg_cim_we      )

    );

    row_copy_controller u_row_copy_controller (

    // global signals
    .clk_in         (HCLK           ),
    .rst_n          (HRESETn        ),

    // reg_set signals
    .addr_in        (reg_addr_out   ),
    .irq_out        (rc_irq_out     ),

    // cim_array
    .irq_in         (cim_array_irq_out),
    .addr_out       (cim_array_addr_in)

    );

    cim_array u_cim_array (

    // global signals
    .clk_in         (HCLK            ),
    .rst_n          (HRESETn         ),

    // row_copy ctrl signals
    .addr_in        (cim_array_addr_in),
    .irq_out        (cim_array_irq_out),

    // reg_set signals
    .din            (reg_cim_data_out),
    .dout           (reg_cim_data_in ),
    .en             (enable          ),
    .we             (reg_cim_we      )
    // dp_ram_array signals
    //.clk_out_a       (clka            ),
    //.clk_out_b       (clkb            ),
    //.dina            (reg_cim_data_out[31:16]),
    //.dinb            (reg_cim_data_out[15:0 ]),
    //.douta           (reg_cim_data_in[31:16]),
    //.doutb           (reg_cim_data_in[15:0 ]),
    //.ena             (1'b1            ),
    //.enb             (1'b1            ),
    //.wea             (cim_wea         ),
    //.web             (cim_web         ),
    //.rsta            (cim_rsta        ),
    //.rstb            (cim_rstb        )

    );

endmodule
