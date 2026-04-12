// -----------------------------------------------------------------------------
// Formal Verification Wrapper: BarrelShifter
// -----------------------------------------------------------------------------
// Proves correctness of the barrel shifter module (BarrelShifter.sv)
// using SymbiYosys with k-induction.
//
// Assertions verified:
// Mode contracts
// Empty Shift
// Sign Extension of Arithmetic Right Shift
//
// Tools: SymbiYosys, Yices solver
// Mode:  prove k-induction, depth 50 and bmc, depth 50
// -----------------------------------------------------------------------------

module BarrelShifter_formal #(
	parameter DATA_W = 32,
	parameter SHAMT_W = 5
) (
	input logic [DATA_W-1:0] data_in,
	input logic [SHAMT_W-1:0] shamt,
	input logic [1:0] mode,
	output logic [DATA_W-1:0] data_out
);

	BarrelShifter #(
		.DATA_W(DATA_W),
		.SHAMT_W(SHAMT_W)
	) dut (
		.data_in(data_in),
		.shamt(shamt),
		.mode(mode),
		.data_out(data_out)
	);

	always_comb begin
		// Mode Asserts: Need to check the functionality of the mode input.
		// Does it correctly assert the desired shift function including the
		// default mode
		if (mode == 2'b00)
			shiftLeftMode: assert (data_out == data_in << shamt);
		if (mode == 2'b01)
			shiftRightMode: assert (data_out == data_in >> shamt);
		if (mode == 2'b10)
			arithmeticRightMode: assert ($signed(data_out) == $signed(data_in) >>> shamt);
		if (mode == 2'b11)
			defaultMode: assert (data_out == data_in << shamt);
		// Empty shift Assert: Does the barrel shifter correctly do nothing
		// when instructed to do nothing?
		if(shamt == 0)
			noShift: assert (data_out == data_in);
		// Sign Extension asserts: Using the arithmetic right shift means
		// accounting for the MSB. Does our shifter correctly shift 1's or 0's
		// in when necessary?
		if (mode == 2'b10 && data_in[DATA_W-1] && shamt != 0)
			signExtend: assert (data_out[DATA_W-1] == 1);
		if (mode == 2'b10 && data_in[DATA_W-1] == 0)
			noSignExtend: assert (data_out[DATA_W-1] == 0);

	end
endmodule
