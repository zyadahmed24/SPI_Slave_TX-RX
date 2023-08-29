module SPI (
    input wire       MOSI,
    input wire       SS_n,
    input wire       clk, 
    input wire       rst_n,
    input wire [7:0] tx_data,
    input wire       tx_valid,

    output reg       MISO,
    output reg [9:0] rx_data,
    output reg       rx_valid
);

reg [4:0] IDLE      = 'b00001;
reg [4:0] CHK_CMD   = 'b00010;
reg [4:0] READ_DATA = 'b00100;
reg [4:0] READ_ADD  = 'b01000;
reg [4:0] WRITE     = 'b10000;

reg [4:0] current;
reg [4:0] next;
reg [4:0] counter;
reg [4:0] counter_reg = 'b0;
reg [9:0] rx_data_reg;
reg       miso_reg;
reg [7:0] tx_data_reg;

reg flag          = 'b0;
reg flag_reg      = 'b0;
reg rx_valid_flag = 'b0;
reg write_flag    = 'b0;
reg clear_counter = 'b0;
reg read_flag     = 'b0;

integer i = 0;

//Next state logic
always @(*) begin
    //flag_reg = 'b0;
    case(current)
        IDLE : begin
            if(SS_n == 'b0)
            begin
                next = CHK_CMD;
            end
            else
            begin
                next = IDLE;
            end
        end
        CHK_CMD : begin
            if(SS_n == 'b1)
            begin
                next = IDLE;
            end
            else
            begin
                if(MOSI == 'b0)
                begin
                    next = WRITE;
                end
                else
                begin
                    if(!flag)
                    begin
                        next = READ_ADD;
                    end
                    else
                    begin
                        next = READ_DATA;
                    end
                end
            end
        end
        READ_ADD : begin
            if(SS_n == 0)
            begin
                next = READ_ADD;
            end
            else
            begin
                next = IDLE;
            end
        end
        READ_DATA : begin
            if(SS_n == 0)
            begin
                next = READ_DATA;
            end
            else
            begin
                next = IDLE;
            end            
        end
        WRITE : begin
            if(SS_n == 0)
            begin
                next = WRITE;
            end
            else
            begin
                next = IDLE;
            end            
        end
        default : begin
            next = IDLE;
            flag_reg = 'b0;
        end
    endcase
end

always @(*) begin
    tx_data_reg = tx_data;
end

//Output logic
always @(*) begin
    case(current)
        IDLE : begin

        end
        CHK_CMD : begin
            write_flag    = 'b0;
            rx_valid_flag = 'b0;
            clear_counter = 'b0;
            read_flag     = 'b0;
            if(MOSI == 'b0 && SS_n == 'b0)
            begin
                write_flag    = 'b1;
                rx_valid_flag = 'b0;
                clear_counter = 'b0;
                flag_reg      = 'b0;
            end
            else if(MOSI == 'b1 && SS_n == 'b0 && flag == 'b0)
            begin
                write_flag    = 'b1;
                rx_valid_flag = 'b0;
                clear_counter = 'b0;
                flag_reg      = 'b1;
            end            
            else if(MOSI == 'b1 && SS_n == 'b0 && flag == 'b1)
            begin
                write_flag    = 'b1;
                read_flag     = 'b1;
                rx_valid_flag = 'b0;
                clear_counter = 'b0;    
                flag_reg      = 'b0;            
            end
            else
            begin
                write_flag    = 'b0;
                rx_valid_flag = 'b0;
                clear_counter = 'b0;
                read_flag     = 'b0;
                flag_reg      = 'b0;     
            end
        end
        WRITE : begin
            if( counter == 'd10)
            begin
                write_flag    = 'b0;
                clear_counter = 'b1;
                rx_valid_flag = 'b1;
            end
        end
        READ_ADD : begin
            if( counter == 'd10)
            begin
                write_flag    = 'b0;
                clear_counter = 'b1;
                rx_valid_flag = 'b1;
            end
        end
        READ_DATA : begin
            if( counter == 'd9)
            begin
                write_flag    = 'b0;
                read_flag     = 'b1;
                rx_valid_flag = 'b1;
            end
            else if( counter == 'd22)
            begin
                write_flag    = 'b0;
                read_flag     = 'b0;
                clear_counter = 'b1;
                rx_valid_flag = 'b0;
            end
        end     
        default : begin
            write_flag    = 'b0;
            rx_valid_flag = 'b0;
            clear_counter = 'b0;
            read_flag     = 'b0;
            flag_reg      = 'b0;
        end   
    endcase
end

//Store element
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        current <= IDLE;
        rx_valid <= 'b0;
        MISO    <= 'b0;
    end
    else
    begin
        current <= next;
        counter <= counter_reg;
        rx_valid <= rx_valid_flag;
        MISO <= miso_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        counter <= 'b0;
    end
    else if( (write_flag == 'b1) || (read_flag == 'b1))
    begin
        counter <= counter + 'b1;
    end
    else if(clear_counter == 'b1)
    begin
        counter <= 'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        rx_data <= 'b0;
    end
    else if(write_flag == 'b1)
    begin
        rx_data <= {rx_data[8:0], MOSI};
    end
end

always @(*) begin
    tx_data_reg = tx_data;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        flag <= 'b0;
    end
    else
    begin
        flag <= flag_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        MISO <= 'b0;
    end
    else if(read_flag == 'b1 && tx_valid == 'b1)
    begin
        {MISO, tx_data_reg[7:1]} <= tx_data_reg;
    end
end

endmodule