module testbench;

    // The input registers to the register file
    reg [7:0] WRITEDATA;
    reg [2:0] READREG1, READREG2, WRITEREG;
    reg CLK, RESET, WRITEENABLE;

    // A wire for the two outputs of the register file
    wire [7:0] REGOUT1, REGOUT2;

    reg_file R1 (WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);         // Instatiation

    // Print the output for any change in the parameters to be printed
    initial 
    begin
        #5
        $monitor ("OUT1: %b        OUT2: %b", REGOUT1, REGOUT2);
    end 

    // Observe the timing on gtkwave
    initial
    begin
        $dumpfile("wavedata.vcd");
        $dumpvars(0,testbench);
    end

    // Update the registers
    initial 
    begin

        // First reset the registers

        CLK = 1'b0;
        RESET = 1'b0;
        WRITEENABLE = 1'b0;

        #1
                // The registers are reset here (Rising clock edge)
        RESET = 1'b1;
        // Read the register values
        READREG1 = 3'b000;              // -> 00110011
        READREG2 = 3'b001;              // -> 00000000

        #2
        RESET = 1'b0;
        // Write to register r0
        
        #2
        WRITEENABLE = 1'b1;
        WRITEREG = 3'b000;
        WRITEDATA= 8'b00110011;


        // // Read the register values
        // READREG1 = 3'b000;              // -> 00110011
        // READREG2 = 3'b001;              // -> 00000000

        #10 $finish;

    end 

    always
        #2 CLK = ~CLK;
endmodule