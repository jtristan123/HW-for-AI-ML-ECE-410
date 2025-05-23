module spi_slave2 (
    input wire clk,
    input wire cs,
    input wire sclk,
    input wire mosi,
    output reg miso
);

reg [7:0] lfsr = 8'b10101010;  // Initial seed (can be anything non-zero)
reg [2:0] bit_cnt = 0;
reg [7:0] tx_buffer = 8'b0;    // Data to shift out (copied from LFSR)

initial begin
    miso = 0;
end

// SPI Receive (shift mosi into nothing, just for protocol)
always @(posedge sclk) begin
    if (!cs) begin
        bit_cnt <= bit_cnt + 1;
    end
end

// SPI Transmit (bit by bit from tx_buffer)
always @(negedge sclk) begin
    if (!cs && bit_cnt < 8)
        miso <= tx_buffer[7 - bit_cnt];
    else
        miso <= 0;
end

// Update LFSR and tx_buffer when a full byte is received
always @(posedge sclk) begin
    if (!cs) begin
        if (bit_cnt == 0) begin
            // Update LFSR and preload buffer at the start of the byte
            lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
            tx_buffer <= lfsr;
        end

        bit_cnt <= bit_cnt + 1;

        if (bit_cnt == 7)
            bit_cnt <= 0;  // Reset after 8 bits total
    end
end


endmodule
