library verilog;
use verilog.vl_types.all;
entity inst_fetch is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        inst_o          : out    vl_logic_vector(31 downto 0)
    );
end inst_fetch;
