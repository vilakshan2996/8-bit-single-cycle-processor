//module for register file
module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);

    //declaring wires/registers
    input [7:0] IN;                                     //input write port
    input [2:0] INADDRESS,OUT1ADDRESS,OUT2ADDRESS;      //input writing address, reading addresses
    input WRITE, CLK, RESET;                            //input control signals
    output reg signed[7:0]OUT1,OUT2;                              //output read registers
    
    reg signed [7:0] register [0:7];        //array of words representing the register(8x8)

    integer i;         //integer to iterate through the register. To reset using for loop

    //Always block to read the register. (Asynchronous) 
    //Sensitive list includes input addresses, last register(to indicate reseting) and writing address
    //Whenever register values are updated this always() block executes
    always @(OUT1ADDRESS, OUT2ADDRESS, register[7], register[INADDRESS]) begin        
        #2                         //read delay of #2
        OUT1 = register[OUT1ADDRESS];       //read value in register specified and set to output 1
        OUT2 = register[OUT2ADDRESS];       //read value in register specified and set to output 2
    end 

    //Always block to reset register and write to register. (Synchronous)
    always @(posedge CLK) begin

        //if RESET signal is high, clear all registers to 0
        if(RESET) begin
        #1                          //reset delay

        for(i=0;i<8;i=i+1) begin      //for loop to iterate over the registers stored as an array of words
            register[i]=8'd0;       //set registers to zero
        end 
        end

        //if WRITE signal is high, write input value to register
        if((!RESET)&&WRITE) begin 
        #1                          //write delay
        register[INADDRESS]=IN;     //write input value into the given register
        end  
    end

    initial begin
        $dumpfile("cpu_wavedata.vcd");
        for(i=0;i<8;i = i+1)
            $dumpvars(1,register[i]);
    end

    // // // printing the register 
    initial begin
		#5;
		// $display("\n\t\t\t___________________");
		// $display("\n\t\t\t CHANGE OF REGISTER CONTENT STARTING FROM TIME #5");
		// $display("\n\t\t\t___________________\n");
		$display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
		$display("\t\t________________________");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7]);
	end
endmodule
