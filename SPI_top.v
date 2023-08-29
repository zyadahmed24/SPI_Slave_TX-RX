module spi_top (
    input  wire MOSI,
    input  wire SS_n,
    input  wire clk, rst_n,
    output wire MISO
);

wire [7:0] tx_data;
wire       tx_valid;
wire [9:0] rx_data;
wire       rx_valid;

SPI slave(MOSI, SS_n, clk, rst_n, tx_data, tx_valid, MISO, rx_data, rx_valid);
ram RAM(rx_data, rx_valid, clk, rst_n, tx_data, tx_valid);

endmodule