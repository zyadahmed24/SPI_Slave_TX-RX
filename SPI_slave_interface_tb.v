`timescale 1ns/1ps

module SPI_tb;

parameter period = 100;
parameter DWIDTH = 8;
parameter DDEPTH = 10;

reg         mosi_tb;
reg         ss_n_tb;
reg         clk_tb;
reg         rst_tb;
reg  [7:0]  tx_data_tb;
reg         tx_valid_tb;
wire        miso_tb;
wire [9:0]  rx_data_tb;
wire        rx_valid_tb;

reg [9:0]   add    = 'b0000000101;
reg [9:0]   dat    = 'b0110100011;
reg [9:0]   rd_add = 'b1000000101;
reg [7:0]   get_add;
reg [7:0]   rec_dat;

reg     [DWIDTH-1:0]     ram     [DDEPTH-1:0];

SPI DUT(mosi_tb, ss_n_tb, clk_tb, rst_tb, tx_data_tb, tx_valid_tb, miso_tb, rx_data_tb, rx_valid_tb);

always #(0.5 * period) clk_tb = ~clk_tb;

initial begin
    //System functions.
    $dumpfile("LFSR_DUMP.vcd") ;       
    $dumpvars; 

    init;

    reset;

    write_add(add);

    write_dat(dat);

    #(30*period);

    read_add;

    #(10*period);

    read_data;

    #(10*period);

    write_add('b0000000011);

    write_dat('b0100010011);

    #(10*period);

    $stop;
end

task init;
begin
    clk_tb  = 'b0;
    rst_tb  = 'b1;
    mosi_tb = 'b0;
    ss_n_tb = 'b1;
end
endtask

task reset;
begin
    rst_tb = 'b0;
    #period;
    rst_tb = 'b1;
end
endtask

task write_add;
input reg [9:0] x;
integer i;
begin
    ss_n_tb = 'b0;
    mosi_tb = 'b0;
    #(period);
    
    for(i=9; i>=0; i=i-1)
    begin
        mosi_tb = x[i];
        #period;
    end

    ss_n_tb = 'b1;
    get_add = rx_data_tb [7:0];
    #(3*period);
end
endtask

task write_dat;
input reg [9:0] x;
integer i;
begin
    ss_n_tb = 'b0;
    mosi_tb = 'b0;
    #(period);

    for(i=9; i>=0; i=i-1)
    begin
        mosi_tb = x[i];
        #period;
    end

    ss_n_tb = 'b1;
    ram [get_add] = rx_data_tb[7:0];
    #(3*period);

end
endtask

task read_add;
integer i;
begin
    ss_n_tb = 'b0;
    mosi_tb = 'b1;
    #(period);

    for(i=9; i>=0; i=i-1)
    begin
        mosi_tb = rd_add[i];
        #period;
    end

    ss_n_tb = 'b1;
    $display("fuck youuuuuu at %0t",$time);
    get_add = rx_data_tb [7:0];
    #(3*period);
    $display("fuck youuuuuu");

end
endtask


task read_data;
integer i;
begin
    ss_n_tb = 'b0;
    mosi_tb = 'b1;
    tx_data_tb = ram [get_add];

    for(i=7; i>=0; i=i-1)
    begin
        rec_dat [i] = miso_tb ;
        #period;
    end

    ss_n_tb = 'b1;
    #(3*period);

end
endtask

endmodule