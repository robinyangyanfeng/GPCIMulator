`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 15:55:36
// Design Name: 
// Module Name: ahb_if
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


module ahb_if(
    
    // AHB Slave Interface Signals
    input               HCLK,
    input               HRESETn,
    input [31:0]        HADDR,
    input [1:0]         HTRANS,
    input               HWRITE,
    input [2:0]         HSIZE,
    input [2:0]         HBRUST,
    input [3:0]         HPROT,
    input [31:0]        HWDATA,
    input               HSELx,
    output reg [31:0]   HRDATA,
    input               HREADY,
    output              HREADY_Out,
    output [1:0]        HRESP,

    // CSR Signals
    output reg [31:0]   reg_addr,
    input  [31:0]       reg_din,
    output reg [31:0]   reg_dout,
    output              reg_we

    );

parameter [1:0]     T_IDLE = 'd0, T_BUSY = 'd1, T_NONS = 'd2, T_SEQ = 'd3;
parameter [1:0]     R_OK = 'd0;

wire        bus_idle        ;
wire        bus_busy        ;
wire        bus_trans       ;
reg         bus_wr_dph      ;   // data phase of write trans
reg         hready_idle     ;
reg         hready_read     ;
wire        hready_rd_w     ;
wire        trans_fir       ;   // first beat of a burst
reg [2:0]   addr_step       ;   // byte addr incr of each trans beat
reg [2:0]   addr_wrap_bloc  ;   // the original addr bit location at wrap point
reg [31:0]  addr_wrap       ;   // first addr after wrap back
wire [31:0] nxt_addr        ;
wire        bus_addr_inc    ;
wire        bus_addr_inc_w  ;   // addr incr of write
reg         wrap_flag       ;

wire        csr_rd          ;
wire        csr_wr          ;

assign  bus_idle        = HSELx & HREADY & (HTRANS == T_IDLE);
assign  bus_busy        = HSELx & HREADY & (HTRANS == T_BUSY);
assign  bus_trans       = HSELx & HREADY & HTRANS[1];
assign  trans_fir       = HSELx & HREADY & (HTRANS == T_NONS);

assign  HRESP           = R_OK;
assign  HREADY_Out      = ((bus_wr_dph)? 1'b1 : hready_rd_w) | hready_idle;

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        hready_idle <= 1'b1;
    else
        hready_idle <= bus_idle | bus_busy;

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        bus_wr_dph  <= 1'b0;
    else
        bus_wr_dph  <= (bus_trans & HWRITE);

always @(*) begin
    case(HSIZE[1:0])
        'd0:    addr_step = 'd1;
        'd1:    addr_step = 'd2;
        'd2:    addr_step = 'd4;
        'd3:    addr_step = 'd4;    // not support
    endcase
end

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn) begin
        addr_wrap_bloc  <= 1'b0;
        addr_wrap       <= 'd0;
    end else if(trans_fir) begin
        case(HSIZE)
            'd0:    begin   // 8b trans
                if(HBRUST[2] == 1'b0) begin
                    addr_wrap_bloc  <= 'd2;
                    addr_wrap       <= {HADDR[31:2], 2'h0};
                end else if(HBRUST[1] == 1'b0) begin // for bl=8
                    addr_wrap_bloc  <= 'd3;
                    addr_wrap       <= {HADDR[31:3], 3'h0};
                end else begin
                    addr_wrap_bloc  <= 'd3;
                    addr_wrap       <= {HADDR[31:4], 4'h0};
                end
            end

            'd1:    begin   // 16b trans
                if(HBRUST[2] == 1'b0) begin     // just cnt for bl=4
                    addr_wrap_bloc  <= 'd3;
                    addr_wrap       <= {HADDR[31:3], 3'h0};
                end else if(HBRUST[1] == 1'b0) begin
                    addr_wrap_bloc  <= 'd4;
                    addr_wrap       <= {HADDR[31:4], 4'h0};
                end else begin
                    addr_wrap_bloc  <= 'd5;
                    addr_wrap       <= {HADDR[31:6], 6'h0};
                end
            end

            default:begin   // 32b trans
                if(HTRANS[2] == 1'b0) begin     // just cnt for bl=4
                    addr_wrap_bloc  <= 'd4;
                    addr_wrap       <= {HADDR[31:4], 4'h0};
                end else if(HBRUST[1] == 1'b0) begin    // for bl=8
                    addr_wrap_bloc  <= 'd5;
                    addr_wrap       <= {HADDR[31:5], 5'h0};
                end else begin
                    addr_wrap_bloc  <= 'd6;
                    addr_wrap       <= {HADDR[31:6], 6'h0};
                end
            end
        endcase
    end

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        wrap_flag       <= 1'b0;
    else if(trans_fir)
        wrap_flag       <= !HBRUST[0];

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        reg_addr        <= 'd0;
    else if(trans_fir)
        reg_addr        <= HADDR[31:0];
    else if(bus_addr_inc) begin
        if(wrap_flag) begin
            if(nxt_addr[addr_wrap_bloc] != addr_wrap[addr_wrap_bloc])
                reg_addr    <= addr_wrap;
            else
                reg_addr    <= nxt_addr; 
        end else begin
            reg_addr    <= nxt_addr;
        end
    end

//--- 1: change ahb lite inf to csr ctrl signals ---//

//--- 1.1: write port

wire    [31:0]      csr_wdata   ;

assign  reg_dout   = HWDATA;

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        csr_wr  <= 1'b0;
    else
        csr_wr  <= bus_addr_inc_w;

//--- 1.2: read port

reg             csr_rd_d    ;
wire [31:0]     csr_dout    ;

assign  csr_rd      = !bus_busy;
assign  hready_rd_w = hready_read;

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn) begin
        csr_rd_d    <= 1'b0;
    end else if(trans_fir || bus_idle) begin
        csr_rd_d    <= 1'b0;
    end else begin
        csr_rd_d    <= csr_rd;
    end

always @(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        hready_read <= 1'b0;
    else if(trans_fir || bus_idle)
        hready_read <= 1'b0;
    else if(csr_rd_d)
        hready_read <= 1'b1;

always @(posedge HCLK)
    if(csr_rd_d)
        HRDATA  <= csr_dout;

assign reg_we = (!csr_rd_d) & (csr_wr);
assign csr_dout = reg_din;

endmodule
