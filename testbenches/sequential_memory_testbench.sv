module sequential_memory_testbench;
    logic clk;
    logic reset;
    logic request_read;
    logic request_write;
    logic [7:0] data_in;
    logic [7:0] data_out;

    sequential_memory #(.DATA_WIDTH(8)) mem (
        .clk(clk),
        .reset(reset),
        .request_write(request_write),
        .request_read(request_read),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    initial begin
        // инициализация
        clk = 0;
        reset = 1;
        data_in = 0;
        request_write = 0;
        request_read = 0;
        #10;
        reset = 0;

        #10;
        request_read = 1;
        #10;
        request_read = 0;

        // запись 16 чисел
        for (int i = 0; i < 16 * 3; i += 3) begin
            data_in = i;
            request_write = 1;
            #10;
            request_write = 0;
            #10;
            if (i % 2 == 0) begin
                request_read = 1;
                #10;
                request_read = 0;
                #10;
            end
        end

        // чтение 16 чисел
        #10;
        for (int i = 0; i < 8; i++) begin
            request_read = 1;
            #10;
            request_read = 0;
            #10;
        end

        $stop;
    end
endmodule
