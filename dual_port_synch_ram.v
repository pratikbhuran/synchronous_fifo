module dual_port_synch_ram #(parameter WIDTH = 8,
parameter ADDR = 2,
parameter DEPTH = 4)
(

    input clk,
    //port 0 input ports
    //port 1 input ports
    input [ADDR-1:0] addr_port0,
    input [ADDR-1:0] addr_port1,
    input chip_sel_port0,
    input chip_sel_port1,
    input wr_rd_port0,
    input wr_rd_port1, 
    input out_en_port0,
    input out_en_port1,

    inout [WIDTH-1:0] data_in_out_port0,
    inout [WIDTH-1:0] data_in_out_port1
    
);

//declare ram
reg [WIDTH-1:0] ram_dual [0:DEPTH-1];

//temp reg for output data
reg [WIDTH-1:0] r0_temp_data_out0;
reg [WIDTH-1:0] r1_temp_data_out1;

//  PORT 0 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//write data in RAM
always @(posedge clk ) begin
   
        if (wr_rd_port0 == 1'b1 && out_en_port0 == 1'b0) begin   //write condition after cs = 1
            ram_dual[addr_port0] <= data_in_out_port0;
        end     
    end


//read operation
//write data in temp reg
always @(posedge clk ) begin
    if(chip_sel_port0 == 1'b1) begin
   
       r0_temp_data_out0 <= ram_dual[addr_port0];            //read operation stored in reg

    end
end

//asynch output assignment to pin from output_reg 
assign  data_in_out_port0 = (chip_sel_port0 == 1'b1 && out_en_port0 == 1'b1) ? r0_temp_data_out0 : 'hz;


// PORT 1
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//write data in RAM
always @(posedge clk ) begin
   
    if (wr_rd_port1 == 1'b1 && out_en_port1 == 1'b0 ) begin   //write condition after cs = 1
        ram_dual[addr_port1] <= data_in_out_port1;
    end     
end


//read operation
//write data in temp reg
always @(posedge clk ) begin
    if(chip_sel_port1 == 1'b1) begin
       r1_temp_data_out1 <= ram_dual[addr_port1];            //read operation stored in reg
    end
end

//asynch output assignment to pin from output_reg 
assign  data_in_out_port1 = (chip_sel_port1 == 1'b1 && out_en_port1 == 1'b1) ? r1_temp_data_out1 : 'hz;

endmodule //dual_port_synch_ram