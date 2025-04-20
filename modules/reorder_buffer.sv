module reorder_buffer #(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    //AR slave interface
    input logic [3:0] s_arid_i,
    input logic s_arvalid_i,
    output logic s_arready_o,
    //R slave interface
    output logic [DATA_WIDTH-1:0] s_rdata_o,
    output logic [3:0] s_rid_o,
    output logic s_rvalid_o,
    input logic s_rready_i,
    //AR master interface
    output logic [3:0] m_arid_o,
    output logic m_arvalid_o,
    input logic m_arready_i,
    //R master interface
    input logic [DATA_WIDTH-1:0] m_rdata_i,
    input logic [3:0] m_rid_i,
    input logic m_rvalid_i,
    output logic m_rready_o
);
    
    logic busy_order;
    logic ready_order;
    logic request_write_order;
    logic request_read_order;
    logic correct_read;
    logic [3 : 0] address;
    logic busy_data;
    logic request_write_data;
    logic busy_out;
    logic wait_address;

    // reset
    always_ff @(posedge rst_n) begin
        s_arready_o <= '0;
        m_rready_o <= '0;
        request_read_order <= '0;
        request_read_order <= '0;
        request_write_data <= '0;
        busy_order <= '0;
        busy_data <= '0;
        busy_out <= '0;
        wait_address <= '1;
    end

    // модуль для хранения порядка идентификаторов
    sequential_memory #(.DATA_WIDTH(4)) order (
        .clk(clk),
        .reset(rst_n),
        .request_write(request_write_order),
        .request_read(request_read_order),
        .data_in(s_arid_i),
        .correct_read(correct_read),
        .data_out(address)
    );

    assign m_arid_o = s_arid_i;
    assign m_arvalid_o = s_arvalid_i;
    always_ff @(posedge s_arvalid_i) begin
        s_arready_o <= '0;
        ready_order <= '1;
    end
    // считывание порядка идентификоторов
    always_ff @(posedge clk) begin
        if (busy_order && m_arready_i) begin
            // идентификатор был прочитан и можно переходить к следующему
            s_arready_o <= '1;
            busy_order <= '0;
            request_write_order <= '0; // обнуление подготовит память к записи
        end else if (s_arvalid_i && ready_order) begin
            // получен новый идентификатор
            ready_order <= '0;
            busy_order <= '1;
            request_write_order <= '1;
        end
    end

    // модуль для хранения пришедших данных
    address_memory #(.DATA_WIDTH(DATA_WIDTH)) data (
        .clk(clk),
        .reset(rst_n),
        .request_write(request_write_data),
        .address_write(m_rid_i),
        .data_in(m_rdata_i),
        .address_read(address),
        .data_out(s_rdata_o)
    );

    // считывание данных
    always_ff @(posedge clk) begin
        if (m_rready_o) begin
            // работа с данными завершилась
            m_rready_o <= '0;
        end else if (busy_data) begin
            // данные сохраняются 
            m_rready_o <= '1;
            busy_data <= '0;
            request_write_data <= '0;
        end else if (m_rvalid_i) begin
            // получены новые данные
            busy_data <= '1;
            request_write_data <= '1;
        end
    end

    assign s_rid_o = address;
    // вывод данных
    always_ff @(posedge clk) begin
        if (request_read_order) begin
            request_read_order <= '0;
        end else if (wait_address) begin
            // нужен идентификатор следующего числа
            if (correct_read) begin
                request_read_order <= '1;
                wait_address <= '0;
            end
        end else if (busy_out && s_rready_i) begin
            // данные прочитаны
            s_rvalid_o <= '0;
            busy_out <= '0;
            wait_address <= '1;
        end else if (!$isunknown(s_rdata_o)) begin
            // появились данные на нужном адресе
            s_rvalid_o <= '1;
            busy_out <= '1;
        end
    end
endmodule
