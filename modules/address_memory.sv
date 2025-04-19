module address_memory #(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic request_write,

    input logic [3 : 0] address_write,
    input logic [DATA_WIDTH - 1 : 0] data_in,

    input logic [3 : 0] address_read,
    output logic [DATA_WIDTH - 1 : 0] data_out
);

    // регистры для хранения 16 чисел DATA_WIDTH
    logic [DATA_WIDTH - 1 : 0] memory [0 : 15];

    // готовность окружения к следующей записи
    logic ready_write;

    // если одна запись завершилась, то можно переходить к следующей
    always_ff @(negedge request_write)
        ready_write <= '1;

    // на выходе всегда число из нужного адреса
    always_ff @(posedge clk)
        data_out <= memory[address_read];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // сброс состояния и памяти
            ready_write <= '1;
            for (int i = 0; i < 16; i++)
                memory[i] <= 'x;
        end else if (request_write && ready_write) begin
            // запись нового числа на данный адрес
            ready_write <= '0;
            memory[address_write] <= data_in;
        end
    end
endmodule
