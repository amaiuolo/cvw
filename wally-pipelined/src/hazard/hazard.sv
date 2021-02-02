///////////////////////////////////////////
// hazard.sv
//
// Written: David_Harris@hmc.edu 9 January 2021
// Modified: 
//
// Purpose: Determine forwarding, stalls and flushes
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
// OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////

`include "wally-config.vh"

module hazard(
  // Detect hazards
//  input  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
//  input  logic       MemReadE, 
//  input  logic       RegWriteM, RegWriteW, 
  input  logic       PCSrcE, CSRWritePendingDEM, RetM, TrapM,
  input  logic       LoadStallD,
  input  logic       InstrStall, DataStall,
  // Stall outputs
  output logic       StallF, StallD, FlushD, FlushE, FlushM, FlushW
);

  logic BranchFlushDE;
  logic StallDCause, StallFCause, StallWCause;
  
  // stalls and flushes
  // loads: stall for one cycle if the subsequent instruction depends on the load
  // branches and jumps: flush the next two instructions if the branch is taken in EXE
  // CSR Writes: stall all instructions after the CSR until it completes, except that PC must change when branch is resolved
  //             this also applies to other privileged instructions such as M/S/URET, ECALL/EBREAK
  // Exceptions: flush entire pipeline
  // Ret instructions: occur in M stage.  Might be possible to move earlier, but be careful about hazards

  // General stall and flush rules:
  // A stage must stall if the next stage is stalled
  // If any stages are stalled, the first stage that isn't stalled must flush.

  assign BranchFlushDE = PCSrcE | RetM | TrapM;

  assign StallDCause = LoadStallD;
  assign StallFCause = InstrStall | CSRWritePendingDEM;
  assign StallWCause = DataStall; // *** not yet used

  assign StallD = StallDCause;
  assign StallF = StallD | StallFCause;
  assign FlushD = BranchFlushDE | StallFCause; //  PCSrcE |InstrStall | CSRWritePendingDEM | RetM | TrapM;
  assign FlushE = StallD | BranchFlushDE; //LoadStallD | PCSrcE | RetM | TrapM;
  assign FlushM = RetM | TrapM;
  assign FlushW = TrapM;
endmodule
