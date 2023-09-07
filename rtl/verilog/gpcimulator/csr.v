`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 18:55:40
// Design Name: 
// Module Name: csr
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


module csr(
    
    // global signals
    input           clk,
    input           rst_n,

    // from ahb lite slave interface
    input   [31:0]  reg_addr,
    input   [31:0]  reg_din,
    output  [31:0]  reg_dout,
    input           reg_we,

    // RCOC signals
    output  [31:0]  inst,   // temple set 'hf0f0_f0f0 as fft compute
    input           irq,    // while irq == 1'b1, the fft computing process end

    // CIM array signals
    output          cim_clka,
    output  [31:0]  cim_addra,
    input   [31:0]  cim_dina,
    output  [31:0]  cim_douta,
    output          cim_ena,

    output          cim_clkb,
    output  [31:0]  cim_addrb,
    input   [31:0]  cim_dinb,
    output  [31:0]  cim_doutb,
    output          cim_enb

    );

    wire    csr_wr, csr_rd;

    assign  csr_wr = reg_we ;
    assign  csr_rd = !reg_we;

    reg [31:0]  start_reg, data_reg, data_h_reg, mode_reg, inst_reg;

    //--- write behavior ---//

    // 0x0000_0001 start flag
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            start_reg <= 32'h0;
        end else if(csr_wr) begin
            if(reg_addr == 32'h0000_0001)
                start_reg <= reg_din;
        end else begin
            start_reg <= start_reg;
        end
    end

    // 0x0000_0002 data register
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            data_reg <= 32'h0;
        end else if(csr_wr) begin
            if(reg_addr == 32'h0000_0002)
                data_reg <= reg_din;
        end else begin
            data_reg <= data_reg;
        end
    end 

    // 0x0000_0003 data_h register
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            data_h_reg <= 32'h0;
        end else if(csr_wr) begin
            if(reg_addr == 32'h0000_0003)
                data_h_reg <= reg_din;
        end else begin
            data_h_reg <= data_h_reg;
        end
    end

    // 0x0000_0004 mode register
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            mode_reg <= 32'h0;
        end else if(csr_wr) begin
            if(reg_addr == 32'h0000_0004)
                mode_reg <= reg_din;
        end else begin
            mode_reg <= mode_reg;
        end
    end

    // 0x0000_0005 inst register
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            inst_reg <= 32'h0;
        end else if(csr_wr) begin
            if(reg_addr == 32'h0000_0005)
                inst_reg <= reg_din;
        end else begin
            inst_reg <= inst_reg;
        end
    end

endmodule
