module reorder_buffer_testbench_dataf;
    logic clk;
    logic rst_n;

    //AR slave interface
    logic [3:0] s_arid_i;
    logic s_arvalid_i;
    logic s_arready_o;
    //R slave interface
    logic [7:0] s_rdata_o;
    logic [3:0] s_rid_o;
    logic s_rvalid_o;
    logic s_rready_i;
    //AR master interface
    logic [3:0] m_arid_o;
    logic m_arvalid_o;
    logic m_arready_i;
    //R master interface
    logic [7:0] m_rdata_i;
    logic [3:0] m_rid_i;
    logic m_rvalid_i;
    logic m_rready_o;

    reorder_buffer #(.DATA_WIDTH(8)) buffer (
        .clk(clk),
        .rst_n(rst_n),
        .s_arid_i(s_arid_i),
        .s_arvalid_i(s_arvalid_i),
        .s_arready_o(s_arready_o),
        .s_rdata_o(s_rdata_o),
        .s_rid_o(s_rid_o),
        .s_rvalid_o(s_rvalid_o),
        .s_rready_i(s_rready_i),
        .m_arid_o(m_arid_o),
        .m_arvalid_o(m_arvalid_o),
        .m_arready_i(m_arready_i),
        .m_rdata_i(m_rdata_i),
        .m_rid_i(m_rid_i),
        .m_rvalid_i(m_rvalid_i),
        .m_rready_o(m_rready_o)
    );

    always #5 clk = ~clk;

    initial begin
        // инициализация
        clk = 0;
        rst_n = 0;

        s_arvalid_i = 0;
        s_arid_i = 'x;
        m_arready_i = 1;

        m_rvalid_i = 0;
        m_rid_i = 'x;
        m_rdata_i = 'x;

        #10;
        rst_n = 1;

        for (int i = 0; i < 16; i++) begin
            #10;
            m_rvalid_i = 1;
            m_rid_i = 15 - i;
            m_rdata_i = 3 * i;
            while (!m_rready_o)
                #10;
            #10; // m_rvalid_i и m_rready_o 1 такт одновременно => приняты
            m_rvalid_i = 0;
            m_rid_i = 'x;
            m_rdata_i = 'x;
        end
        #10;

        for (int i = 0; i < 16; i++) begin
            #10;
            s_arvalid_i = 1;
            s_arid_i = i;
            m_arready_i = 0;
            while (!m_arvalid_o)
                #10;
            m_arready_i = 1;
            while(!s_arready_o)
                #10;
            #10; // s_arvalid_i и s_arready_o 1 такт одновременно => приняты
            s_arvalid_i = 0;
            s_arid_i = 'x;
        end
        #10;


        for (int i = 0; i < 16; i++) begin
            while (!s_rvalid_o)
                #10;
            s_rready_i = '1;
            #10; // s_rvalid_o и s_rready_i 1 такт одновременно => приняты
            s_rready_i = '0;
        end
        #10;

        $stop;
    end
endmodule
