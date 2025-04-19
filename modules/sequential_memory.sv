module sequential_memory #(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic request_write,
    input logic request_read,

    input logic [DATA_WIDTH - 1 : 0] data_in,

    output logic correct_read,

    output logic [DATA_WIDTH - 1 : 0] data_out
);

    // регистры для хранения 16 чисел DATA_WIDTH
    logic [DATA_WIDTH - 1 : 0] memory [0 : 15];

    // счетчик текущего адреса
    logic [3 : 0] address_write;
    logic [3 : 0] address_read;

    // показатель, что последнее число прочитано
    logic finish_write;

    // готовность вывода очередного числа
    assign correct_read = ((address_read < address_write) || finish_write);

    // готовность окружения к следующему действию
    logic ready_write;
    logic ready_read;

    // если один запрос завершился, то можно переходить к следующему
    always_ff @(negedge request_write)
        ready_write <= '1;
    always_ff @(negedge request_read)
        ready_read <= '1;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // сброс адреса, состояния и выхода
            address_write <= '0;
            address_read <= '0;
            ready_write <= '1;
            ready_read <= '1;
            data_out <= 'x;
        end else if (request_write && ready_write) begin
            // запись числа на текущий адрес
            ready_write <= '0;
            memory[address_write] = data_in;
            {finish_write, address_write} = address_write + 1;
        end else if (request_read && ready_read && correct_read) begin
            // чтение с текущего адреса
            ready_read <= '0;
            data_out = memory[address_read];
            address_read = address_read + 1;
        end
    end
endmodule
