/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

//Edited by: Group 06
            // E/18/147
            // E/18/379

`timescale 1ns/100ps

module instruction_cache(BUSYWAIT, readinst, mem_READ, mem_ADDRESS, READ, ADDRESS, mem_BUSYWAIT, mem_READDATA, CLK, RESET);
    
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */
  
    //CPU Side
    output reg BUSYWAIT;
    output reg[31:0] readinst;

    input READ, CLK, RESET;
    input[9:0]  ADDRESS;

    //Instruction Memory Side
    output reg mem_READ;
    reg mem_readTemp;
    output reg [5:0] mem_ADDRESS;

    input mem_BUSYWAIT;
    input[127:0] mem_READDATA;

    //declare 8 cache blocks of size 130bits each. 4bytes to store + valid bit+ dirty bit + tag(3bits) + index(3bits) = 40bits    
    reg[134:0] cacheBlock [0:7];

    //bit to determine hit or miss
    reg hit;
    reg[2:0] Tag, Index;
    reg[1:0] Offset;

    //Detecting an incoming memory access
    reg readaccess, writeaccess;

    //finding the cache entry
    integer i;

    //to identify readhit and writehit
    reg readhit, writehit;

    //to extract valid bit, dirty bit and tag of block
    reg valid;
    reg [2:0]tagOfBlock;

    //extract data block
    reg[31:0] dataBlock [0:3];
    reg[31:0] loadInstruction;

    //to trigger block to find hit after memory read
    reg tagChange=0;

    //trigger to identify hits
    reg hitTrigger=0;

    reg flag;

    //initialize cache block;
    initial begin
        cacheBlock[0] = {3'd0, 1'b0, 3'bx, 128'bx};
        cacheBlock[1] = {3'd1, 1'b0, 3'bx, 128'bx};
        cacheBlock[2] = {3'd2, 1'b0, 3'bx, 128'bx};
        cacheBlock[3] = {3'd3, 1'b0, 3'bx, 128'bx};
        cacheBlock[4] = {3'd4, 1'b0, 3'bx, 128'bx};
        cacheBlock[5] = {3'd5, 1'b0, 3'bx, 128'bx};
        cacheBlock[6] = {3'd6, 1'b0, 3'bx, 128'bx};
        cacheBlock[7] = {3'd7, 1'b0, 3'bx, 128'bx};
    end

    //set readaccess and writeaccess
    always @(READ)
    begin
	    BUSYWAIT = (READ )? 1 : 0;
	    readaccess = (READ )? 1 : 0;
    end

    //to extract valid, dirty and tag of block and datablock
    always @(readaccess, ADDRESS, tagChange) begin

        //set valid,dirty,datablock accordinally
        if(readaccess) begin
            #1

            Tag = ADDRESS[9:7];
            Index = ADDRESS[6:4];
            Offset = ADDRESS[3:2];                                  //Word offset (ignoring the last two bits)

            valid=cacheBlock[Index][131];
            tagOfBlock=cacheBlock[Index][130:128];
            
            dataBlock[3]=cacheBlock[Index][127:96];
            dataBlock[2]=cacheBlock[Index][95:64];
            dataBlock[1]=cacheBlock[Index][63:32];
            dataBlock[0]=cacheBlock[Index][31:0];

            hitTrigger=~hitTrigger;
        end
    end

    //reg mem_readTemp;
    
    //get hit
    //always @(Tag, tagOfBlock, valid) 
    always @ (hitTrigger) begin
            //determine hit
            if(readaccess && valid && (tagOfBlock==Tag)) begin 
                #0.9 
                hit=1;
                //writehit = 1'b0;
            end 
            else begin
                #0.9
                //if(readaccess) 
                mem_readTemp = 1'b1;
                //mem_ADDRESS = {Tag,Index};
                mem_READ = mem_readTemp;
                hit=0;
                flag = 0;
                //writehit = 1'b1;
            end 
    end

    // always @ (hitTrigger) begin 
    //     #1
    //     if(!hit && readaccess)  mem_READ = 1'b1;
    // end 

    

    //set writehit readhit and read data
    always @(hitTrigger)
    begin 
        
        //Loading the requested instruction and writing it to the CPU
        if(readaccess) begin
        
        #1
        loadInstruction = dataBlock[Offset];

        if(hit) begin
            if(readaccess)  readhit=1;
            if(!readaccess) readhit=0;
            BUSYWAIT=0;
        end
        else begin
            readhit = 0;
            //writehit= 0;
        end
        end

        //read data in parallel with hit determination
        if(readhit)
        begin 
            readinst=loadInstruction;             //get 8bit data
        end 
    end 

    /* Cache Controller FSM Start */
    parameter IDLE = 3'b000, MEM_READ = 3'b001;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((readaccess) && !hit)  begin      //if miss and cacheblock not dirty move on to memread
                    //mem_READ = 1'b1;
                    next_state = MEM_READ;
                end
                else
                    next_state = IDLE;                                  //else on idle

            //if memory busywait=1 stay on mem read else move on to idle 
            MEM_READ:
                if (!mem_BUSYWAIT)  begin                                     
                    next_state = IDLE;
                    //flag = 1'b1;
                end
                else    
                    next_state = MEM_READ;
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin

                //if mem read=1 go on to update cacheblocks and trigger tagchange
                if(flag) begin
                    #1 
                    mem_READ = 0;
                    mem_readTemp = 1'b0;
                    cacheBlock[Index][127:0] = mem_READDATA;       //update data block
                    cacheBlock[Index][131]   =1'b1;               //update valid bit to one
                    cacheBlock[Index][130:128]= Tag;  //set tag
                    flag = 0;
                    tagChange = ~tagChange;
                    
                end

                else begin
                    //if readaccess=1 or writeaccess=1 not make cache BUSYWAIT 0
                    if(readaccess) begin
                        mem_READ = 0;
                        mem_ADDRESS = 8'dx;
                        //mem_WRITEDATA = 8'dx;
                    end

                    //if readaccess=0 and writeaccess=0 make cache BUSYWAIT 0
                    else begin
                        mem_READ = 0;
                        mem_ADDRESS = 8'dx;
                        BUSYWAIT=0;
                    end
                    
                end
            end
         
            MEM_READ: 
            begin
                mem_READ = 1;
                mem_readTemp = 1'b1;
                if(!mem_BUSYWAIT) flag = 1;
                mem_ADDRESS = {Tag, Index};
                BUSYWAIT = 1;
            end
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge CLK, RESET)
    begin
        if(RESET)
            state = IDLE;
        else
            state = next_state;
    end
    /* Cache Controller FSM End */

    initial begin
        $dumpfile("cpu_wavedata.vcd");
        for(i=0;i<8;i = i+1)
            $dumpvars(1,cacheBlock[i]);
        for(i=0;i<3;i = i+1)
            $dumpvars(1,dataBlock[i]);
    end

endmodule