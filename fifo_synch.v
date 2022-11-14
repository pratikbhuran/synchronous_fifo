module fifo_synch #(parameter DEPTH = 4,
parameter WIDTH = 8,
parameter ADDR = 2
)(
  input clk,
  input rst_n,
  input chip_sel_wr,  
  input chip_sel_rd,
  input wr_en,
  input rd_en,

  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out,
  output reg fifo_full,
  output reg fifo_empty

);

reg w_fifo_full;
reg w_fifo_empty;

//counter for read and write pointer
reg [DEPTH-1:0] r_count;
//address pointer for write operation
reg [ADDR-1:0] r_wr_pointer; 
//address pointer for read operation
reg [ADDR-1:0] r_rd_pointer; 

//instance of dual port ram
//using port 0 to write , port 1 to read data
dual_port_synch_ram dual_port_ram(.clk(clk),
.chip_sel_port0(chip_sel_wr),
.chip_sel_port1(chip_sel_rd),
.wr_rd_port0(wr_en),
.wr_rd_port1(rd_en),
.out_en_port0(1'b0),
.out_en_port1(1'b1),
.data_in_out_port0(data_in),
.data_in_out_port1(data_out),
.addr_port0(r_wr_pointer),
.addr_port1(r_rd_pointer));



//write control logic
always @(posedge clk, negedge rst_n ) begin
    //reset condition
    if(~rst_n) begin
        r_wr_pointer <= 'b0;
        r_count <= {DEPTH{1'b0}};
        w_fifo_full <= 1'b0;
        w_fifo_empty <= 1'b0;
    end
    else begin
        //case 1 assume pointer at start address of fifo
        //write data in fifo with wr_pointer pointing at the address till it is full
        if (chip_sel_wr == 1'b1 && wr_en == 1'b1 && r_count < (DEPTH-1) ) begin
            r_wr_pointer <= r_wr_pointer + 1;            //incrementing address location inside fifo to enter data
            r_count <= r_count + 1;                      //incremet counter till the depth of fifo is reached
            w_fifo_full <= 1'b0;                         //keep full flag low untill fifo is full
            w_fifo_empty <= 1'b0;                        //empty flag should be low while data is entered

        end
        
        else begin
        //when fifo is full , counter reached last location of fifo
          if (r_count ==  (DEPTH-1) && wr_en == 1'b1 ) begin
            r_wr_pointer <= r_wr_pointer;                //keep the pointer at last address location when fifo is full
            r_count <= {DEPTH{1'b0}};                    //reset counter, for read operation to use the counter
            w_fifo_full <= 1'b1;                         //fifo is full, assert full flag
            w_fifo_empty <= 1'b0;                        //keep empty flag low
  
          end
        end
    end
end

//read control logic
always @(posedge clk, negedge rst_n ) begin
    //reset condition
    if(~rst_n) begin
        r_count <= {DEPTH{1'b0}};
        r_rd_pointer <= 'b0;
        w_fifo_full <= 1'b0;
        w_fifo_empty <= 1'b0;
    end
    else begin
        //case 1 => when fifo is full and pointer pointing at start address location  
        if (chip_sel_rd == 1'b1 && rd_en == 1'b1 && r_count < (DEPTH-1) ) begin
            r_count <= r_count + 1;                        //incremet counter till the depth of fifo is reached
            r_rd_pointer <= r_rd_pointer + 1;              //increment address location inside fifo starting from first location 
            w_fifo_full <= 1'b0;                           //assert full flag low when first data is read
            w_fifo_empty <= 1'b0;                          //keep empty flag low untill pointer reaches last location
            

        end
        else begin
        //when the counter reaches last location of read operation
            if (r_count == (DEPTH-1) && rd_en == 1'b1 && r_rd_pointer == (DEPTH -1)) begin
            r_count <= {DEPTH{1'b0}};
            r_rd_pointer <= {ADDR{1'b0}};
            w_fifo_full <= 1'b0;
            w_fifo_empty <= 1'b1;
            
        end
    end 
 end
end


//assign flag register to output 
always @ * begin
    fifo_full = w_fifo_full;
    fifo_empty = w_fifo_empty;
end

endmodule //fifo_synch