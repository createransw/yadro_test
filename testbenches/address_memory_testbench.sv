module address_memory_testbench;
    logic clk;
    logic reset;
    logic request_write;
    logic [3 : 0] address_write;
    logic [7 : 0] data_in;
    logic [3 : 0] address_read;
    logic [7 : 0] data_out;

    address_memory #(.DATA_WIDTH(8)) mem (
        .clk(clk),
        .reset(reset),
        .request_write(request_write),
        .address_write(address_write),
        .data_in(data_in),
        .address_read(address_read),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    initial begin
        // инициализация
        clk = 0;
        reset = 1;
        address_write = 0;
        data_in = 0;
        request_write = 0;
        address_read = 0;
        #10;
        reset = 0;

        // запись 16 чисел
        for (int i = 0; i < 16; i++) begin
            address_write = i;
            data_in = 3 * i;
            #10;
            request_write = 1;
            #10;
            request_write = 0;
            #10;

            address_read = (address_read + 5) % 16;
        end

        // чтение 16 чисел
        #10;
        for (int i = 0; i < 16; i++) begin
            address_read = i;
            #10;
        end

        $stop;
    end
endmodule
