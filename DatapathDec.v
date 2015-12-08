//testing all changes 

module Datapath();

                        reg Clk, reset;

                        reg [31:0] instruction;
                        wire Clr;
                        /*  Enables*/
                        wire RFE, IRE, MDRE, MARE, PCRE, MEME, SRE, SIE, BSE, BITE;

                        /*  Muxes Selectors*/
                        wire M2S, M5S, M6S;
                        wire [2:0] M1S, M7S;
                        wire [1:0] M3S, M4S;

                        /*Instruction register*/
                        wire [31:0] IRO;

                        /*  Estos son los cables de la memoria */
                        wire RW, MEMS;
                        wire MFC;
                        reg [1:0] VS;

                        wire [31:0] MEMO, MDRO, MARO;

                        /*  Estos son los cables de el shifter (que todavia no esta implementado)*/
                        wire [31:0] RSO, SIO;


                        /*  Estos son los cables de mux de Register File  */
                        wire [3:0] M6O, M5O, M4O;
                        wire [31:0] M3O;
                        wire [4:0] M7O;

                        /*  Estos son los cables de register file */
                        wire [31:0] PA, PB;


                        /*  Los cables del MDR */
                        wire [31:0] M2O;
                        //Variable del ALU
                        wire [31:0] ALUO;

                        wire [3:0] Flags;
                        reg [4:0] opcode;
                        wire [31:0] M1O;

                        wire Cin;

                        /*  Los cables del Brache sign extension */
                        wire [31:0] BSO;

                        /*  Los cables del Bit  extension */
                        wire [31:0] BEO;


/*  Los cables del ER  */
                        wire [31:0] ERO;

                        /*  Los cables del ER  */
                        wire [3:0] SRO;


                       RegisterFile RF (PA,PB, M3O, M5O, M6O, M4O, RFE, reset, Clk);


                        /* Instanciando los multiplexers*/
                        mux_8 M1 (M1O, M1S, BEO,  32'h1, BSO, 32'h000004, RSO, SIO, IRO, MDRO) ;
                        mux_2 M2 (M2O, M2S,  ALUO, MEMO);
                        mux_4 M3 (M3O, M3S, BEO, BSO, ALUO, MDRO);

                        mux_4_4 M4 (M4O, M4S, 4'hE, 4'hF, IRO[15:12], IRO[19:16]);
                        mux_2_4 M5 (M5O, M5S, 4'hF, IRO[19:16]);
                        mux_2_4 M6 (M6O, M6S, IRO[15:12], IRO[3:0]);


                         mux_8_5 M7(M7O, M7S, 5'b01000, IRO[24:20], 5'b00100, 5'b11010, 5'b11011, 5'b11110,5'b11111, 5'b0, Clk);




                        //instanciando los reistros que estan en el data path
                        Register32 IR (IRO, MDRO , IRE, Clr);
                        Register32 MDR (MDRO, M2O, MDRE, Clr);

                        Register4 SR (SRO, Flags, SRE, Clr, Clk);

                        Register32 MAR (MARO, ALUO, MARE, Clr);


                        



                      branch_sign_extension BS(BSO, IRO[23:0], BSE);

                      bit_extension BE (BEO, IRO[11:0], BITE);
                        /* Instanciando de memoria (hay que verificar que las entradas estan puestan en el lugar adecuado)*/
                        memory_256 memory256 (MEMO, MFC, MDRO, MARO, VS, RW, MEME, MEMS, Clk);
                        //module memory_256 (VALOUT, MFC, VALIN, ADDRESS, VALSIZE, RW, MEME, VALSIGN);




                        /*Instanciacion del control unit*/
                        wire [63:0] pipelineRegisterO;
                 controlUnitModule CU (pipelineRegisterO, SRO, IRO, MFC, reset, Clk);
                 
                 assign M1S = pipelineRegisterO [63:61];
                 assign M2S = pipelineRegisterO [60];
                 assign M3S = pipelineRegisterO [59:58];
                 assign M4S = pipelineRegisterO [57:56];
                 assign M5S = pipelineRegisterO [55];
                 assign M6S = pipelineRegisterO [54];
                 assign M7S = pipelineRegisterO [53:51];
                 assign RFE = pipelineRegisterO [50];
                 assign IRE = pipelineRegisterO [49];
                 assign MDRE = pipelineRegisterO [48];
                 assign MARE = pipelineRegisterO [47];
                 assign PCRE = pipelineRegisterO [46];
                 assign MEME = pipelineRegisterO [45];
                 assign SRE = pipelineRegisterO [44];
                 assign SIE = pipelineRegisterO [43];
                 assign RSE = pipelineRegisterO [42];
                 assign BSE = pipelineRegisterO [41];
                 assign RW = pipelineRegisterO [40];
                 assign MEMS = pipelineRegisterO [39];
                 assign BITE = pipelineRegisterO [38];
                 assign Clr = pipelineRegisterO [37];
                 
                 
                 /*
                 M1S, M4S, M2S, M3S, M5S, M6S, M7S, Cin, RFE, IRE, MDRE, MARE, PCRE, MEME,BITE, SRE, SIE, RSE,
                    BSE, RW, MEMS, Clr, SRO, IRO, Clk, reset, MFC);
                */

// module control_Unit(output reg [2:0] M1S, M4S, output reg M2S, output reg [1:0] M3S,  output reg M5S, M6S,
//           output reg [2:0] M7S, output reg  Cin, RFE, IRE, MDRE, MARE, PCRE, MEME, SRE, SIE, RSE, BSE, RW, MEMS, Clr,
//           input [3:0] SRO, input [31:0] IRO, input Clk, reset, mfc);


                        // Valin Valor de entrada
                        // address lugar donde esta guardado o se va a guardad
                        //MFC transaction complete, 0 no termino y 1 termino
                        // val size la longitud de la valin
                        // RW, si 1 read y si es 0 es write
                        // MEME es un enable
                        //VALSIZE puede coger tres valores, 00 es byte, 01 half-word , 10 word
                        //Valsign cuando haces store no afecta nada, cuando hace el load afecta ya que hace sign extension.

                        //Instanciando el ALU

                        //module ALU (output reg [31:0] result, output reg [3:0] Flags, input signed [31:0] A, B, input [4:0] opcode, input Cin, input [2:0] tribit);
                        ALU alu (ALUO , Flags, PA, M1O, M7O, Cin, IRO[27:25], Clk);



                        /*Todavia shifter no esta implementado*/
                        shift_reg RS (RSO, PB, IRO[11:5], Clr, RSE, Clk);
                        shift_immed SI (SIO, IRO, Clr, SIE, Clk);



                        initial #2600 $finish;



                        initial begin


                        Clk = 1'b0;

                        repeat(1500)
                        begin
                        #100 Clk = ~Clk;
                        if(Clk == 1)begin
                        $display("\n Address: %b", CU.ROM.stateAddress);
                        $display(" Control Signals: %b", CU.ROM.controlSignals);
                        $display(" Clr: %b", Datapath.Clr);
                        $display(" MFA: %b (%b)", memory256.MFA, Datapath.pipelineRegisterO[45]);
                        $display(" RW: %b", memory256.RW);
                        $display(" VALSIGN: %b (%b)", memory256.VALSIGN, Datapath.pipelineRegisterO[39]);
                        $display(" VALSIZE: %b", memory256.VALSIZE);
                        $display(" MFC: %b", memory256.MFC);
                        $display(" VALOUT: %b", memory256.VALOUT);
                        $display(" MDR: %b (IN %b) (OUT %b)", MDR.LE, MDR.D, MDR.Q);
                        $display(" MUX2: %b (%b)", M2.S, M2.Y);
                        $display(" MARE: %b (IN %b) (OUT %b)", MAR.LE, MAR.D, MAR.Q);
                        $display(" PC: %b (IN %b) (OUT %b)", RF.R15.LE, RF.R15.D, RF.R15.Q);
                        $display(" MUX4: %b (%b)", M4.S, M4.Y);
                        $display(" IRE: %b (IN %b) (OUT %b)", IR.LE, IR.D, IR.Q);
                        $display(" Clock: ", $time);
                        $display(" MUX5: %b (%b), MUX7: %b (%b), MARE: %b (%b), RFE: %b, MUX4O: %b, MUX3O: %b, MEME: %b, MDRE: %b (%b), RFA: %b, RFB: %b, MUX1: %b (%b), ALUO: %b, muxRomIn: %b, Clock: ", M5.S, M5.Y, M7.S, M7.Y, Datapath.MARE, Datapath.MARO, Datapath.RFE, M4.Y, M3.Y, Datapath.MEME, Datapath.MDRE, Datapath.MDRO, RF.PA, RF.PB, M1.S, M1.Y, alu.result, CU.muxRomIn.S, $time );
                        $display(" Pipeline Datapath: %b", Datapath.pipelineRegisterO);
                        $display("\n --------------------------------------------------------------------------");
                        end
                        end
                         end

                        initial fork
                        //Clr = 1;
                        VS = 2'b10;
                        reset = 1;
                        #19 reset = 0;
                        //$monitor("MDRO: %b", MDRO);
                        //$display("PC\t\t\t\t M4P\t\t\t M3P\t\t\t ALU\t\t\t Clk\RC\t Time"); //imprime header
                        //$monitor (" %b %b %b %b %b", RF.R15.D, Clr, memory256.MEM[1], Clk, $time); //imprime variables
                         //$monitor ("The value that will be stored into the memory is %b. This value will be stored at the address %b. After performing the Store instruction, the resulting value stored at the provided address is %b %b %b %b.  Tribit %b. ALU Opcode %b. ALU Result %b. Flags %b. Value of ALU B %b. Value of ALU A %b. Register File PB %b. Register File PA %b. Register File RB %b. Register File RA %b. MDR Value %b. MAR Value %b. MEME %b vs MEME %b. MFC %b vs RAM MFC %b.", RF.R0.Q, RF.R1.Q, memory256.MEM[32'h0], memory256.MEM[32'h1], memory256.MEM[32'h2], memory256.MEM[32'h3], alu.tribit, alu.opcode, alu.result, alu.Flags, alu.B, alu.A, RF.PB, RF.PA, RF.RB, RF.RA, MDRO, MARO, MEME, memory256.MEME, MFC, memory256.MFC);
                        join

                        endmodule



           module branch_sign_extension (output reg [31:0] extended, input [23:0] toExtend, input enable);
         always @ (toExtend, enable)

         //es activo low
         if (enable) extended <=  32'b0;

         else begin
           extended <= { {8{toExtend[23]}}, toExtend[23:0] };

            extended <= extended<<(4'b0100);
           // extended << 4;
            end


         endmodule

                        //Multiplexer de 2 entradas
                        module mux_2 (output reg [31:0] Y, input S, input [31:0] I0, I1);


                        always @ (S, I0, I1)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        1'b0: Y = I0;
                        1'b1: Y = I1;

                        endcase


                        endmodule

                        //Multiplexer de 2 entradas de 4 bits
                        module mux_2_4 (output reg [3:0] Y, input S, input [3:0] I0, I1);


                        always @ (S, I0, I1)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        1'b0: Y = I0;
                        1'b1: Y = I1;

                        endcase


                        endmodule

                        //Multipleer de 4 entradas
                        module mux_4 (output reg [31:0] Y, input [1:0] S, input [31:0] I0, I1, I2, I3);


                        always @ (S, I0, I1, I2, I3)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        4'b00: Y = I0;


                        4'b01: Y = I1;
                        4'b10: Y = I2;
                        4'b11: Y = I3;
                        endcase


                        endmodule

                        //Multipleer de 4 entradas
                        module mux_4_4 (output reg [3:0] Y, input [1:0] S, input [3:0] I0, I1, I2, I3);


                        always @ (S, I0, I1, I2, I3)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        4'b00: Y = I0;
                        4'b01: Y = I1;
                        4'b10: Y = I2;
                        4'b11: Y = I3;
                        endcase

        endmodule

                       module mux_8_4 (output reg [3:0] Y, input [2:0] S, input [3:0] I0, I1, I2, I3, I4, I5, I6, I7);

                        always @ (S, I0, I1, I2, I3, I4, I5, I6, I7)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        4'b000: Y = I0;
                        4'b001: Y = I1;
                        4'b010: Y = I2;
                        4'b011: Y = I3;
                        4'b100: Y = I4;
                        4'b101: Y = I5;
                        4'b110: Y = I6;
                        4'b111: Y = I7;
                        endcase
                        endmodule

        //Multipleer de 4 entradas y 5 bis por entrada.
                        module mux_8_5 (output reg [4:0] Y, input [2:0] S, input [4:0] I0, I1, I2, I3, I4, I5, I6, I7, input Clk);

                        always @ (Clk)
                        //S, I0, I1, I2, I3, I4, I5, I6, I7)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        4'b000: Y = I0;
                        4'b001: Y = I1;
                        4'b010: Y = I2;
                        4'b011: Y = I3;
                        4'b100: Y = I4;
                        4'b101: Y = I5;
                        4'b110: Y = I6;
                        4'b111: Y = I7;
                        endcase
                        endmodule
                        //Multipleer de 8 entradas
                        module mux_8 (output reg [31:0] Y, input [2:0] S, input [31:0] I0, I1, I2, I3, I4, I5, I6, I7);


                        always @ (S, I0, I1, I2, I3, I4, I5, I6, I7)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        3'b000: Y = I0;
                        3'b001: Y = I1;
                        3'b010: Y = I2;
                        3'b011: Y = I3;
                        3'b100: Y = I4;
                        3'b101: Y = I5;
                        3'b110: Y = I6;
                        3'b111: Y = I7;

                        endcase



                        endmodule


                         module bit_extension (output reg [31:0] extended, input [11:0] toExtend,  input enable);
                          always @ (toExtend, enable)
           //es activo low
                           if (enable) extended <=  32'b0;

                           else extended[31:0] = {20'b0, toExtend[11:0]};

                          endmodule
                        /*
                        This is the code for the ALU
                        Made by Ibraim
                        */
                        module ALU (output reg [31:0] result, output reg [3:0] Flags, input signed [31:0] A, B, input [4:0] opcode, input Cin, input [2:0] tribit, input Clk);
                                always @ (posedge Clk, opcode, negedge Clk)
                                //opcode or A or B)
                                begin                                                                           // the second case of each one is which the bit s as one which would affect the flags
                                        if(tribit != 3'b010 && tribit != 3'b011)
                                        begin

                                        case (opcode)
                                                5'b00000: result = A & B;         // AND
                                                5'b00001: result = A & B;
                                                5'b00010: result = A ^ B;          // EOR
                                                5'b00011: result = A ^ B;
                                                5'b00100: result = A - B;         // SUB
                                                5'b00101: result = A - B;
                                                5'b00110: result = B - A;               // reverseSUB
                                                5'b00111: result = B - A;
                                                5'b01000: result = A + B;           // ADD
                                                5'b01001: result = A + B;
                                                5'b01010: result = A + B + Cin;    //  ADDC
                                                5'b01011: result = A + B + Cin;
                                                5'b01100: result = A - B - ~Cin;   // SUBC
                                                5'b01101: result = A - B - ~Cin;
                                                5'b01110: result = B - A - ~Cin;         // reverseSUBC
                                                5'b01111: result = B - A - ~Cin;
                                                5'b1000x: result = A & B;         // TST
                                                5'b1000x: result = A & B;
                                                5'b1001x: result = A ^ B;        // TEQ
                                                5'b1001x: result = A ^ B;
                                                5'b1010x: result = A - B;        // CMP
                                                5'b1010x: result = A - B;
                                                5'b1011x: result = A + B;        // CMPN
                                                5'b1011x: result = A + B;
                                                5'b11000: result = A | B;        // ORR
                                                5'b11001: result = A | B;
                                                5'b11010: result =  A;           // MOV
                                                5'b11011: result =  B;
                                                5'b11100: result = A & ~B;              //BIC
                                                5'b11101: result = A & ~B;
                                                5'b11110: result = A + 32'h4;              //MVN
                                                5'b11111: result = B + 32'h4;
                                        endcase
                                        end
                                        else
                                        begin
                                                #20 if(B != 32'hAAAAAAAA)
                                                begin
                                                        result = B;
                                                end
                                                else
                                                begin
                                                        result = A;
                                                end
                                        end

                                        Flags = 4'b0000;
                                        // Change flags
                                        if(opcode == 5'b01001 ||  opcode == 5'b01011 || opcode == 5'b1011x)
                                        begin
                                          Flags[1] = result[31];                                                                            // N flag
                                          Flags[0] = (A[31] & B[31] & (~result[31])) | ((~A[31]) & (~B[31]) & result[31]);  // V flag
                                          Flags[3] = (A[31] & B[31]) | ((!result[31]) & (A[31] | B[31]));                   // C flag
                                          Flags[2] = (result == 0) ? 1'b1 : 1'b0;                                                           // Z flag
                                        end
                                        else if(opcode == 5'b00101 ||  opcode == 5'b01101 || opcode == 5'b1010x || opcode == 5'b01111 || opcode == 5'b00111)
                                        begin
                                           Flags[1] = result[31];                                                                           // N flag
                                           Flags[2] = (result == 0) ? 1'b1 : 1'b0;                                                          // Z flag
                                           Flags[3] = ((~A[31]) & B[31]) | (result[31] & ((~A[31]) | B[31]));               // C flag
                                           Flags[0] = (A[31] & (~B[31]) & (~result[31])) | ((~A[31]) & B[31] & result[31]); // V flag
                                        end
                                        else if (opcode == 5'b00001 || opcode == 5'b00010 || opcode == 5'b11001
                                                || opcode == 5'b1110x || opcode == 5'b1000x || opcode == 5'b1001x)
                                        begin
                                                Flags[1] = result[31];                                                                          // N flag
                                                Flags[2] = (result == 0) ? 1'b1 : 1'b0;                                                         // Z flag
                                                Flags[0] = 0;                                                                                   // V flag
                                                Flags[3] = 0;                                                                                   // C flag
                                        end
                                end
                        endmodule

                        /*
                        This is the code for the register file and it's components (such as Register and mux, etc)
                        Made by Emanuel
                        */
                        module RegisterFile (output [31:0] PA, PB, input [31:0] PC, input [3:0] RA, RB, RC, input RFE, Clr, Clk);

                        //wire for the decoder output
                        wire [15:0] DO;
                        //wires of the registers output
                        wire [31:0] RO0, RO1, RO2, RO3, RO4, RO5, RO6, RO7, RO8, RO9, RO10, RO11, RO12, RO13, RO14, RO15;

                        //always @(posedge Clk, negedge Clr) //make changes when any of these changes



                        //Decoder for determining the register that is going to be writing on
                        decoder4_x16 D1 (DO, RC, RFE);

                        //16 registers created (or instantiated)
                        Register32 R0 (RO0, PC, !DO[0], Clr);
                        Register32 R1 (RO1, PC, !DO[1], Clr);
                        Register32 R2 (RO2, PC, !DO[2], Clr);
                        Register32 R3 (RO3, PC, !DO[3], Clr);
                        Register32 R4 (RO4, PC, !DO[4], Clr);
                        Register32 R5 (RO5, PC, !DO[5], Clr);
                        Register32 R6 (RO6, PC, !DO[6], Clr);
                        Register32 R7 (RO7, PC, !DO[7], Clr);
                        Register32 R8 (RO8, PC, !DO[8], Clr);
                        Register32 R9 (RO9, PC, !DO[9], Clr);
                        Register32 R10 (RO10, PC, !DO[10], Clr);
                        Register32 R11 (RO11, PC, !DO[11], Clr);
                        Register32 R12 (RO12, PC, !DO[12], Clr);
                        Register32 R13 (RO13, PC, !DO[13], Clr);
                        Register32 R14 (RO14, PC, !DO[14], Clr);
                        Register32 R15 (RO15, PC, !DO[15], Clr);

                        //MUX FOR PA (the output)
                        mux_16 MA (PA, RA, RO0, RO1, RO2, RO3, RO4, RO5, RO6, RO7, RO8, RO9, RO10, RO11, RO12, RO13, RO14, RO15);

                        //MUX FOR PB (the output)
                        mux_16 MB (PB, RB, RO0, RO1, RO2, RO3, RO4, RO5, RO6, RO7, RO8, RO9, RO10, RO11, RO12, RO13, RO14, RO15);

                        endmodule




                        //This is the mux of 32
                        module Register32 (output reg [31:0] Q, input [31:0] D, input LE, Clr);
                        always @ (posedge Clr, LE, D)

                        if (Clr) Q <= 32'h00000000;
                        //is enabled to be written

                        else if(~LE) Q <= D;
                            else if(LE) Q <= Q;

                        endmodule


                        //Multipleer de 16 entradas
                        module mux_16 (output reg [31:0] Y, input [3:0] S, input [31:0] I0, I1, I2, I3, I4,I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15);


                        always @ (S, I0, I1, I2, I3, I4,I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15)
                        //Depending of the input the output of the mux is going to change
                        case (S)
                        4'b0000: Y = I0;
                        4'b0001: Y = I1;
                        4'b0010: Y = I2;
                        4'b0011: Y = I3;
                        4'b0100: Y = I4;
                        4'b0101: Y = I5;
                        4'b0110: Y = I6;
                        4'b0111: Y = I7;
                        4'b1000: Y = I8;
                        4'b1001: Y = I9;
                        4'b1010: Y = I10;
                        4'b1011: Y = I11;
                        4'b1100: Y = I12;
                        4'b1101: Y = I13;
                        4'b1110: Y = I14;
                        4'b1111: Y = I15;
                        endcase


                        endmodule

                        //decoder of 4 by 16
                        module decoder4_x16 (output reg [15:0] out_a, input [3:0] select, input enable);
                                        always @ (select,enable)
                        //This makes the decoder be an active low since it's the inverse of the entrance
                                        if (!enable)
                                        begin
                                        //Depending of the input the output of the decoder is going to change

                                        case (select)
                                                        4'b0000: out_a = 16'h0001;
                                                        4'b0001: out_a = 16'h0002;
                                                        4'b0010: out_a = 16'h0004;
                                                        4'b0011: out_a = 16'h0008;
                                                        4'b0100: out_a = 16'h0010;
                                                        4'b0101: out_a = 16'h0020;
                                                        4'b0110: out_a = 16'h0040;
                                                        4'b0111: out_a = 16'h0080;
                                                        4'b1000: out_a = 16'h0100;
                                                        4'b1001: out_a = 16'h0200;
                                                        4'b1010: out_a = 16'h0400;
                                                        4'b1011: out_a = 16'h0800;
                                                        4'b1100: out_a = 16'h1000;
                                                        4'b1101: out_a = 16'h2000;
                                                        4'b1110: out_a = 16'h4000;
                                                        4'b1111: out_a = 16'h8000;

                                        endcase
                                        end
                                        //is not enabled
                                        else
                                        begin
                                        out_a = 16'h0000;
                                        end

                        endmodule

                                                module Register4 (output reg [3:0] Q, input [3:0] D, input LE, Clr, Clk);
                        always @ (posedge Clk, negedge Clr, LE)

                        if (Clr) Q <= 4'h0;
                        //is enabled to be written
                        else if(~LE) Q <= D;
                            else if(LE) Q <= Q;

                        endmodule


                        /*
                        This is the code for the memory
                        Made by David
                        */
 module memory_256 (VALOUT, MFC, VALIN, ADDRESS, VALSIZE, RW, MFA, VALSIGN, Clk);

            // Valin Valor de entrada
            // address lugar donde esta guardado o se va a guardad
            // val size la longitud de la valin
            // RW, si 1 read y si es 0 es write
            // MFA es un enable

            //Specifying ouput variables
            output reg [31:0] VALOUT;
            output reg MFC;

            //Specifying input variables
            input [31:0] VALIN;
            input [31:0] ADDRESS;
            input [1:0] VALSIZE;
            input RW;
            input MFA;
            input VALSIGN;
            input Clk;

            //Specifying module variables
            reg [31:0] PSEUDOADDRESS;

            reg NEXTADDRESS;
            reg [7:0] MEM [0:255];

            reg [7:0] TEMPBYTE;
            reg [15:0] TEMPHWORD;

            //Precharge Memory Variables
            integer fd, code, i;
            reg [7:0] data;

            //Precharge Memory
            initial begin
                MFC = 0;
                fd = 0;
                data = 8'b0;
                fd = $fopen("testcode_arm1.txt", "r");
                i = 0;
                while (!($feof(fd)))
                begin
                    code = $fscanf(fd, "%b", data);
                    memory256.MEM[i] = data;
                    $display("Data read from file location %d: %b", i, data);
                    $display("Data saved to memory location %d: %b", i, memory256.MEM[i]);
                    i = i + 1;
                end
                $fclose(fd);
                $display("Memoria: %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b\n         %b %b %b %b", memory256.MEM[0], memory256.MEM[1], memory256.MEM[2], memory256.MEM[3], memory256.MEM[4], memory256.MEM[5], memory256.MEM[6], memory256.MEM[7], memory256.MEM[8], memory256.MEM[9], memory256.MEM[10], memory256.MEM[11], memory256.MEM[12], memory256.MEM[13], memory256.MEM[14], memory256.MEM[15], memory256.MEM[16], memory256.MEM[17], memory256.MEM[18], memory256.MEM[19], memory256.MEM[20], memory256.MEM[21], memory256.MEM[22], memory256.MEM[23], memory256.MEM[24], memory256.MEM[25], memory256.MEM[26], memory256.MEM[27], memory256.MEM[28], memory256.MEM[29], memory256.MEM[30], memory256.MEM[31], memory256.MEM[32], memory256.MEM[33], memory256.MEM[34], memory256.MEM[35], memory256.MEM[36], memory256.MEM[37], memory256.MEM[38], memory256.MEM[39], memory256.MEM[40], memory256.MEM[41], memory256.MEM[42], memory256.MEM[43], memory256.MEM[44], memory256.MEM[45], memory256.MEM[46], memory256.MEM[47]);
                //MFC = 1;
            end

             //This code will always execute whenever there's a change in MFA which is the memory function enable
            always @(MFA)
            begin
                    PSEUDOADDRESS = ADDRESS; //Saves ADDRESS to a local variable called PSEUDOADDRESS because input variables canot be modified within a module

                    if(MFA == 1) //Check to see if MEMORY execution is Enabled, if so, execute the following code
                    begin
                    if(RW == 1'b1) //Are we performing a read operation? (RW == 1)? If so, execute the following code
                    begin

                        if(VALSIGN == 0) //If number is unsigned
                        begin
                            VALOUT = 32'b00000000000000000000000000000000; //Resets VALOUT to 0, this way unsigned loading doesn't leave trash in VALOUT variable
                            if(VALSIZE == 2'b00)
                            begin

                                VALOUT[7:0] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read 8 Bits: %b", PSEUDOADDRESS);
                                MFC = 1'b1;

                            end

                            if(VALSIZE == 2'b01)
                            begin

                                VALOUT[15:8] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read 16 Bits [1]: %b", PSEUDOADDRESS);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                VALOUT[7:0] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read 16 Bits [0]: %b", PSEUDOADDRESS);
                                MFC = 1'b1;

                            end

                            if(VALSIZE == 2'b10)
                            begin

                                VALOUT[31:24] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read 32 Bits [3]: %b, MFA: %b, MFC: %b\n Control_Signals MFA: %b, Time:", PSEUDOADDRESS, MFA, MFC, Datapath.pipelineRegisterO[45], $time);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                VALOUT[23:16] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read 32 Bits [2]: %b, MFA: %b, MFC: %b\n Control_Signals MFA: %b, Time:", PSEUDOADDRESS, MFA, MFC, Datapath.pipelineRegisterO[45], $time);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                VALOUT[15:8] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read 32 Bits [1]: %b, MFA: %b, MFC: %b\n Control_Signals MFA: %b, Time:", PSEUDOADDRESS, MFA, MFC, Datapath.pipelineRegisterO[45], $time);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                VALOUT[7:0] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read 32 Bits [0]: %b, MFA: %b, MFC: %b\n Control_Signals MFA: %b, Time:", PSEUDOADDRESS, MFA, MFC, Datapath.pipelineRegisterO[45], $time);
                                $display("MFC: %b", MFC);
                                MFC = 1'b1;
                                $display("MFC: %b", MFC);

                            end
                        end

                        else //Else means number is signed
                        begin
                            if(VALSIZE == 2'b00)
                            begin

                                TEMPBYTE = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read Signed 8 Bits [0]: %b", PSEUDOADDRESS);
                                VALOUT[7:0] = $signed(TEMPBYTE);
                                MFC = 1'b1;

                            end

                            if(VALSIZE == 2'b01)
                            begin

                                TEMPHWORD[15:8] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read Signed 16 Bits [1]: %b", PSEUDOADDRESS);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                TEMPHWORD[7:0] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read Signed 16 Bits [0]: %b", PSEUDOADDRESS);

                                VALOUT = $signed(TEMPHWORD);
                                MFC = 1'b1;

                            end

                            if(VALSIZE == 2'b10)
                            begin

                                VALOUT[31:24] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read Signed 32 Bits [3]: %b", PSEUDOADDRESS);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                VALOUT[23:16] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read Signed 32 Bits [2]: %b", PSEUDOADDRESS);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                VALOUT[15:8] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read Signed 32 Bits [1]: %b", PSEUDOADDRESS);
                                PSEUDOADDRESS = PSEUDOADDRESS + 1;
                                VALOUT[7:0] = MEM[PSEUDOADDRESS];
                                $display("Localización Para Read Signed 32 Bits [0]: %b", PSEUDOADDRESS);
                                MFC = 1'b1;

                            end
                        end

                    end

                    if(RW == 1'b0)
                        if(VALSIZE == 2'b00)
                        begin                    begin


                            MEM[PSEUDOADDRESS] = VALIN[7:0];
                            PSEUDOADDRESS = PSEUDOADDRESS + 1;
                            $display("Localización Para Write 8 Bits [0]: %b", PSEUDOADDRESS);
                            MFC = 1'b1;

                        end

                        if(VALSIZE == 2'b01)
                        begin

                            MEM[PSEUDOADDRESS] = VALIN[15:8];
                            $display("Localización Para Write 16 Bits [1]: %b", PSEUDOADDRESS);
                            PSEUDOADDRESS = PSEUDOADDRESS + 1;
                            MEM[PSEUDOADDRESS] = VALIN[7:0];
                            $display("Localización Para Write 16 Bits [0]: %b", PSEUDOADDRESS);
                            MFC = 1'b1;
                        end

                        if(VALSIZE == 2'b10)
                        begin

                            MEM[PSEUDOADDRESS] = VALIN[31:24];
                            $display("Localización Para Write 32 Bits [3]: %b", PSEUDOADDRESS);
                            PSEUDOADDRESS = PSEUDOADDRESS + 1;
                            MEM[PSEUDOADDRESS] = VALIN[23:16];
                            $display("Localización Para Write 32 Bits [2]: %b", PSEUDOADDRESS);
                            PSEUDOADDRESS = PSEUDOADDRESS + 1;
                            MEM[PSEUDOADDRESS] = VALIN[15:8];
                            $display("Localización Para Write 32 Bits [1]: %b", PSEUDOADDRESS);
                            PSEUDOADDRESS = PSEUDOADDRESS + 1;
                            MEM[PSEUDOADDRESS] = VALIN[7:0];
                            $display("Localización Para Write 32 Bits [0]: %b", PSEUDOADDRESS);
                            MFC = 1'b1;
                        end
                    end





                    end
                    else
                    begin
                        MFC = 1'b0;
                    end

            end


            endmodule



                        /*
                        Code for shifter register
                        */

                        module shift_reg (output reg [31:0] shifted, input [31:0] registerValue, input [6:0] toShift, input Clr, SE, Clk);

                        always @ (posedge Clk, negedge Clr)



                        if (!Clr)  shifted <= 32'h00000000;

                        //it's  disabled, so dont switch
                        else if (!SE) shifted = registerValue;


                        else begin

                        case (toShift[1:0])
                        2'b00:  shifted <=registerValue<<(toShift[6:2]);    //LSL
                        2'b01:   shifted <=registerValue>>(toShift[6:2]);  //LSR

                        2'b10:  shifted <=registerValue>>>(toShift[6:2]);  //ASR

                        2'b11:     shifted= {registerValue, registerValue} >> toShift[6:2];   //ROR
                        endcase

                        end
                        endmodule


                        module shift_immed(output reg [31:0] shifted, input [31:0] toShift, input Clr, SE, Clk);
                        reg [31:0] temp;

                        always @ (Clk or posedge Clr)
                        if (Clr)fork
                        shifted <= 32'h00000000;
                        //#5 $display("THE SHIFTER RAN CLEAR");
                        join

                        //it's  disabled, so dont switch
                        else if (!SE)fork  //shifted = toShift[7:0];
                        temp[31:0] = 32'h00000000;
                        #3 temp [31:0] = { 24'b0, toShift[7:0] };
                        #5 shifted [31:0] = temp [31:0];
                        //#8 $display("THE SHIFTER RAN SE == 0!!!! SHIFTED VALUE: %b", shifted);
                        join
                        else fork
                        //32 bit immediate shifter operand
                        //if (toShift[27:25] == 3'b001)begin

                        temp = 32'h00000000;

                        #3 temp[7:0] = toShift[7:0];
                        //multiplying by two the amount to shift and shift it
                        #5 temp <=temp<<<(toShift[11:8]*2'b10);
                        //take of the result the bits form 0 to 11
                        #7 shifted = temp;
                        //#9 $display ("THE SHIFTER RAN SE == 1!!!! SHIFTER VALUE: %b", shifted);

                        //end

                        join
                        endmodule


module controlUnitModule(output [63:0] pipelineRegisterO, input [3:0] SRO, input [31:0] IRO, input MFC, Clr, Clk);

    wire [63:0] muxRomInO; //Flows into the ROM from the ROM INPUT MUX
    wire [63:0] irEncoderO; //Flows into the ROM INPUT MUX (0) from the IR ENCODER
    wire [63:0] pipelineRegisterO; //These are the control signals
    wire [63:0] incrementRegisterO; //Flows into the ROM INPUT MUX (3) from the ADDRESS INCREMENT REGISTER
    wire [1:0] nextStateAddressSelectorO; //Flows into the ROM INPUT MUX (S) from the NEXT STATE ADDRESS SELECTOR
    wire [63:0] incrementO; //Flows into the ADDRESS INCREMENT REGISTER
    wire [63:0] romO;
    wire conditionCheckerO;
    
    // variables that already exist in datapath
    //wire [3:0] SRO;
    //wire [31:0] IRO;    
    //wire MFC;    
    //wire Clr;
    //reg Clk;
    
    //Flags[3] Carry, Flags [1] Negative, Flags [3] Zero

    mux_4in_64b    muxRomIn (muxRomInO, nextStateAddressSelectorO, irEncoderO, 64'b0000000000000000000000000000100, pipelineRegisterO, incrementRegisterO);
    //Instance the MUX for selecting ROM INPUT
    //Selector: 2 bit selector from NEXT STATE ADDRESS SELECTOR
    //Inputs: 32 bits from IR ENCODER OUTPUT, 32'b0, PIPELINE OUTPUT [CURRENT STATE ADDRESS], INCREMENT REGISTER OUTPUT

    incrementer incrementOne (incrementO, muxRomInO);
    //Instance the INCREMENTER (+1) 
    //Inputs: CURRENT STATE ADDRESS
    //Outputs: CURRENT STATE ADDRESS + 1;
    
    register32NoE incrementRegister (incrementRegisterO, incrementO, Clr, Clk);
    //Instance the INCREMENTER's REGISTER
    //Inputs: CURRENT STATE ADDRESS + 1, Clk, Clr
    //Behaviour: Will update output at every Clk cycle (does not require an enable), will clear if Clr signal is sent to the register
    
    assign pipelineRegisterO = romO;
    //register32NoE pipelineRegister (pipelineRegisterO, romO, Clr, Clk);
    //Instance the PIPELINE's REGISTER
    //Inputs: ROM OUTPUT (Control Signals)
    //Behaviour: Will update output at every Clk cycle (does not require an enable), will clear if Clr signal is sent to the register
        
    microstore ROM (romO, muxRomInO, Clr, Clk);
    //Instance the 32-bit Cell ROM
    //Input comes from the MUX for selecting ROM INPUT (muxRomIn)
    //Output flows into PIPELINE REGISTER
    
    nextStateAddressSelectorModule nextStateAddressSelector (nextStateAddressSelectorO, pipelineRegisterO, MFC, conditionCheckerO);
    //Instance the nextStateAddressSelector
    //Input comes from PIPELINE REGISTER and CONDITIONAL CHECKER
    //Output flows into ROM INPUT MUX

    conditionCheckerModule conditionChecker (conditionCheckerO, SRO, IRO);
    //Instance the conditionChecker
    //Input flows in from SRO and IRO
    //Output flows into nextStateAddressSelector
    
    
    
endmodule
 
 module microstore (controlSignals, stateAddress, Clr, Clk);
    output reg [63:0] controlSignals;
    input [63:0] stateAddress;
    input Clr, Clk;
    
    reg [6:0] cutStateAddress;
    reg [63:0] ROM [0:255];
    
    //reg [63:0] stateAddressTemp;
    
    //Precharge Memory Variables
    integer fd, code, i;
    reg [63:0] data;
    //Precharge Memory
    initial begin
                fd = 0;
                data = 64'b0;
                fd = $fopen("control_signals.txt", "r");
                i = 0;
                while (!($feof(fd)))
                begin
                    code = $fscanf(fd, "%b", data);
                    microstore.ROM[i] = data;
                    //$display("Data read from file location %d: %b", i, data);
                    $display("Data saved to memory location %d: %b", i, microstore.ROM[i]);
                    i = i + 1;
                end
                $fclose(fd);    
    end
            
            
            always @(posedge Clr, posedge Clk)
            begin
            cutStateAddress = stateAddress [6:0];
            if(Clr == 1)
            begin
                            controlSignals = 64'b00000000000000000000000000000000; //Resets VALOUT to 0, this way unsigned loading doesn't leave trash in VALOUT variable
            end
            else
            begin
                            controlSignals = ROM[cutStateAddress[6:0]];
            end
            end
            
 endmodule
 
module mux_4in_64b (output reg [63:0] Y, input [1:0] S, input [63:0] I0, I1, I2, I3);
                        
            always @ (S, I0, I1, I2, I3)
            begin
                //Depending of the input the output of the mux is going to change
                case (S)
                4'b00: Y = I0;
                4'b01: Y = I1;
                4'b10: Y = I2;
                4'b11: Y = I3;
                endcase
            end
endmodule


module incrementer (output reg [63:0] plusOne, input [63:0] currentStateAddress);
    always @(currentStateAddress)        
    plusOne = currentStateAddress + 1;
endmodule

module register32NoE (output reg [63:0] Q, input [63:0] D, input Clr, Clk);
    always @ (posedge Clk, posedge Clr)
    begin
    if (Clr) Q <= 64'h00000000;
    //is enabled to be written
    else Q <= D;
    end
endmodule

module nextStateAddressSelectorModule (output reg [1:0] nextStateAddressSelectorO, input [63:0] pipelineRegisterO, input MFC, conditionCheckerO);
    always @ (pipelineRegisterO, MFC)
    begin
        case(pipelineRegisterO[8:7])
        2'b00: begin if(conditionCheckerO == 1) nextStateAddressSelectorO = 2'b00; else nextStateAddressSelectorO = 2'b01; end
        2'b01: begin if(MFC == 1) nextStateAddressSelectorO = 2'b11; else nextStateAddressSelectorO = 2'b10; end
        2'b10: nextStateAddressSelectorO = 2'b11;
        2'b11: nextStateAddressSelectorO = 2'b01;
        endcase
    end
endmodule

module conditionCheckerModule (output reg result, input [3:0] SRO, input [31:0] IRO);
   reg Z;
   reg N;
   reg V;
   reg C;
 always @ (SRO)
   begin
      Z = SRO[2];
      N = SRO[1];
      V = SRO[0];
      C = SRO[3];
   end
 always @ (IRO)                                                                           
    begin
        case (IRO [31:28])
        4'b0000: result = Z;         // checks equal condition
        4'b0001: result = !Z;
        4'b0010: result = C;          
        4'b0011: result = !C;
        4'b0100: result = N;        
        4'b0101: result = !N;
        4'b0110: result = V;               
        4'b0111: result = !V;
        4'b1000: result = (C && !Z);           
        4'b1001: result = (!C || Z);
        4'b1010: result = (N == V);    
        4'b1011: result = (N != V);
        4'b1100: result = !Z && (N==V);   
        4'b1101: result = Z || (N == !V);
        4'b1110: result = 1;         
        endcase
        end
endmodule
