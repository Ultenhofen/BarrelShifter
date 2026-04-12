// This made me want to blow my brains out
// Just use << and >>

module BarrelShifter #(
	parameter DATA_W = 32,
	parameter SHAMT_W = 5
) (
	input logic [DATA_W-1:0] data_in,
	input logic [SHAMT_W-1:0] shamt,
	input logic [1:0] mode,
	output logic [DATA_W-1:0] data_out
);

	logic [DATA_W-1:0] stage [SHAMT_W:0];

	always_comb begin
		stage[0] = data_in;
		case (mode)
			2'b00: begin // logic left
				for (int i = 0; i < SHAMT_W; i++) begin
					if (shamt[i]) begin
						for (int j = 0; j < DATA_W; j++) begin
							if (j >= (1 << i)) stage[i+1][j] = stage[i][j - (1<<i)];
							else stage[i+1][j] = 1'b0;
						end
					end else stage[i+1] = stage[i];
				end
			end
			2'b01: begin // logic right
				for (int i = 0; i < SHAMT_W; i++) begin
					if (shamt[i]) begin
						for (int j = 0; j < DATA_W; j++) begin
							if (j < DATA_W - (1 << i)) stage[i+1][j] = stage[i][j + (1<<i)];
							else stage[i+1][j] = 1'b0;
						end
					end else stage[i+1] = stage[i];
				end
			end
			2'b10: begin // arithmetic right
				for (int i = 0; i < SHAMT_W; i++) begin
					if (shamt[i]) begin
						for (int j = 0; j < DATA_W; j++) begin
							if (j < DATA_W - (1 << i)) stage[i+1][j] = stage[i][j + (1<<i)];
							else stage[i+1][j] = stage[i][DATA_W-1];
						end
					end else stage[i+1] = stage[i];
				end
			end
			default: begin // Default to logic left
				for (int i = 0; i < SHAMT_W; i++) begin
					if (shamt[i]) begin
						for (int j = 0; j < DATA_W; j++) begin
							if (j >= (1 << i)) stage[i+1][j] = stage[i][j - (1<<i)];
							else stage[i+1][j] = 1'b0;
						end
					end else stage[i+1] = stage[i];
				end
			end
		endcase
		data_out = stage[SHAMT_W]; 
	end
endmodule
