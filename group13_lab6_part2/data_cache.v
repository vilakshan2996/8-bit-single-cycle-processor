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

module data_cache(BUSYWAIT, READDATA, mem_READ, mem_WRITE, mem_WRITEDATA, mem_ADDRESS, READ, WRITE, WRITEDATA, ADDRESS, mem_BUSYWAIT, mem_READDATA, CLK, RESET);
    
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */
  
    //CPU Side
    output reg BUSYWAIT;
    output reg[7:0] READDATA;

    input READ, WRITE, CLK, RESET;
    input[7:0] WRITEDATA, ADDRESS;

    //Data Memory Side
    output reg mem_READ, mem_WRITE;
    output reg[31:0] mem_WRITEDATA;
    output reg [5:0] mem_ADDRESS;

    input mem_BUSYWAIT;
    input[31:0] mem_READDATA;

    //declare 8 cache blocks of size 40bits each. 4bytes to store + valid bit+ dirty bit + tag(3bits) + index(3bits) = 40bits    
    reg[39:0] cacheBlock [0:7];

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
    reg dirty;
    reg [2:0]tagOfBlock;

    //extract data block
    reg[7:0] dataBlock [0:3];

    //to trigger block to find hit after memory read
    reg tagChange=0;

    //trigger to identify hits
    reg hitTrigger=0;

    //initialize cache block;
    initial begin
        cacheBlock[0] = {1'b0, 1'b0, 3'd0, 3'bx, 32'bx};
        cacheBlock[1] = {1'b0, 1'b0, 3'd1, 3'bx, 32'bx};
        cacheBlock[2] = {1'b0, 1'b0, 3'd2, 3'bx, 32'bx};
        cacheBlock[3] = {1'b0, 1'b0, 3'd3, 3'bx, 32'bx};
        cacheBlock[4] = {1'b0, 1'b0, 3'd4, 3'bx, 32'bx};
        cacheBlock[5] = {1'b0, 1'b0, 3'd5, 3'bx, 32'bx};
        cacheBlock[6] = {1'b0, 1'b0, 3'd6, 3'bx, 32'bx};
        cacheBlock[7] = {1'b0, 1'b0, 3'd7, 3'bx, 32'bx};
    end

    //set readaccess and writeaccess
    always @(READ, WRITE)
    begin
	    BUSYWAIT = (READ || WRITE)? 1 : 0;
	    readaccess = (READ && !WRITE)? 1 : 0;
	    writeaccess = (!READ && WRITE)? 1 : 0;
    end

    //to extract valid, dirty and tag of block and datablock
    always @(readaccess, writeaccess, ADDRESS, tagChange) begin

        //set valid,dirty,datablock accordinally
        if(readaccess||writeaccess) begin
            #1

            Tag = ADDRESS[7:5];
            Index = ADDRESS[4:2];
            Offset = ADDRESS[1:0];

            valid=cacheBlock[Index][39];
            dirty=cacheBlock[Index][38];
            tagOfBlock=cacheBlock[Index][34:32];
            
            dataBlock[0]=cacheBlock[Index][31:24];
            dataBlock[1]=cacheBlock[Index][23:16];
            dataBlock[2]=cacheBlock[Index][15:8];
            dataBlock[3]=cacheBlock[Index][7:0];

            hitTrigger=~hitTrigger;
        end
    end

    //get hit
    always @(Tag, tagOfBlock, valid) begin
            //determine hit
            if(readaccess && valid && (tagOfBlock==Tag)) #0.9 hit=1;
            else if(writeaccess && (tagOfBlock==Tag)) #0.9 hit=1;
            else #0.9 hit=0;
    end

    //set writehit readhit and read data
    always @(hitTrigger)
    begin 
        #1
        if(readaccess || writeaccess) begin
        //if hit set busywait 0 and set readhit and writehit
        if(hit) begin
            if(readaccess)  readhit=1;
            if(writeaccess)  writehit=1;
            if(!readaccess) readhit=0;
            if(!writeaccess) writehit=0;
            BUSYWAIT=0;
        end
        else begin
            readhit = 0;
            writehit=0;
        end
        end

        //read data in parallel with hit determination
        if(readaccess)
        begin 
            READDATA=dataBlock[Offset];             //get 8bit data
        end 
    end 

    //write to cacheblock
    always @(posedge CLK) begin
    //write hit
        if(writehit) begin
            #1
            cacheBlock[Index][39]=1'b1;             //update valid bit
            cacheBlock[Index][38]=1'b1;             //update dirty bit
            dataBlock[Offset]=WRITEDATA;            //write to datablock
            cacheBlock[Index][31:0]={dataBlock[0], dataBlock[1], dataBlock[2], dataBlock[3]};   //write to cache      
        end
    end  

    /* Cache Controller FSM Start */
    parameter IDLE = 3'b000, MEM_READ = 3'b001, CACHE_WRITE=3'b100, MEM_WRITE=3'b010, CACHE_READ=3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((readaccess||writeaccess) && !dirty && !hit)        //if miss and cacheblock not dirty move on to memread
                    next_state = MEM_READ;  
                else if ((READ||WRITE) && dirty && !hit)                //if miss and dirty move on to mem write
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;                                  //else on idle

            //if memory busywait=1 stay on mem read else move on to idle 
            MEM_READ:
                if (!mem_BUSYWAIT)                                      
                    next_state = IDLE;
                else    
                    next_state = MEM_READ;

            //if memory busywait=1 stay on mem write else move on to mem read 
            MEM_WRITE:
                if (!mem_BUSYWAIT)
                    next_state = MEM_READ;
                else    
                    next_state = MEM_WRITE;

        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin

                //if mem read=1 go on to update cacheblocks and trigger tagchange
                if(mem_READ) begin
                    #1 mem_READ = 0;
                    mem_WRITE = 0 ;
                    cacheBlock[Index][31:0] =mem_READDATA;     //update data block
                    cacheBlock[Index][39]   =1'b1;              //update valid bit to one
                    cacheBlock[Index][38]   =1'b0;              //update dirty bit to zero
                    cacheBlock[Index][34:32]=mem_ADDRESS[5:3];  //set tag
                    tagChange = ~tagChange;
                end

                else begin
                    //if readaccess=1 or writeaccess=1 not make cache BUSYWAIT 0
                    if(readaccess||writeaccess) begin
                        mem_READ = 0;
                        mem_WRITE = 0;
                        mem_ADDRESS = 8'dx;
                        mem_WRITEDATA = 8'dx;
                    end

                    //if readaccess=0 and writeaccess=0 make cache BUSYWAIT 0
                    else begin
                        mem_READ = 0;
                        mem_WRITE = 0;
                        mem_ADDRESS = 8'dx;
                        mem_WRITEDATA = 8'dx;
                        BUSYWAIT=0;
                    end
                    
                end
            end
         
            MEM_READ: 
            begin
                mem_READ = 1;
                mem_WRITE = 0;
                mem_ADDRESS = {Tag, Index};
                mem_WRITEDATA = 32'dx;
                BUSYWAIT = 1;
            end

            MEM_WRITE: 
            begin
                mem_READ = 0;
                mem_WRITE = 1;
                mem_ADDRESS = {cacheBlock[Index][34:32], Index};
                mem_WRITEDATA = cacheBlock[Index][31:0];
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