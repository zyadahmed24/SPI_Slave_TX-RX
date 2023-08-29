module ram (
    input  wire [9:0] din,
    input  wire       rx_valid,
    input  wire       clk,rst_n,
    output reg  [7:0] dout,
    output reg        tx_valid
);

parameter DWIDTH = 8;
parameter DDEPTH = 10;

reg [9:0] received_data;
reg [7:0] write_add;
reg [7:0] write_add_reg;
reg [7:0] read_add;
reg [7:0] read_add_reg;
reg [7:0] dout_reg;
reg       tx_valid_reg;
reg [DWIDTH-1:0] mem [DDEPTH-1:0];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        received_data <= 'b0;
    end
    else if(rx_valid == 'b1)
    begin
        received_data <= din;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        write_add <= 'b0;
    end
    else 
    begin
        write_add <= write_add_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        read_add <= 'b0;
    end
    else 
    begin
        read_add <= read_add_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        dout <= 'b0;
    end
    else 
    begin
        dout <= dout_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        tx_valid <= 'b0;
    end
    else 
    begin
        tx_valid <= tx_valid_reg;
    end
end

always @(*) begin
    case(received_data[9:8])
        'b00 : begin
            tx_valid_reg = 'b0;
            write_add_reg = received_data [7:0];
        end
        'b01 : begin
            tx_valid_reg = 'b0;
            mem [write_add] = received_data [7:0];
        end
        'b10 : begin
            tx_valid_reg = 'b0;
            read_add_reg = received_data [7:0];
        end
        'b11 : begin
            tx_valid_reg = 'b1;
            dout_reg = mem [read_add];
        end
        default : begin
            tx_valid_reg  = 'b0;
            write_add_reg = 'b0;
            read_add_reg  = 'b0;
        end
    endcase
end
    
endmodule