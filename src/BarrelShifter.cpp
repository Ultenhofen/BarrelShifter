#include "VBarrelShifter.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <cstdlib>
#include <ctime>
#include <iostream>

int main(int argc, char** argv) {
	srand(time(NULL));
	
	int expected = 0;

	union di_t {
		uint32_t u;
		int32_t s;
	};
	
	struct testCase {
		di_t di;
		uint8_t m;
		uint8_t s;
	};

	testCase caseArray[] = {
		{{.u = 1}, 0, 4},
		{{.u = 4000000}, 1, 20},
		{{.s = -4000000}, 2, 20},
		{{.u = 16}, 3, 5},
		{{.u = 0x00000000}, 0, 5},
		{{.u = 0xffffffff}, 1, 31},
		{{.u = 0xAAAAAAAA}, 0, 16},
		{{.u = 0x80000000}, 2, 31}
	};

	VerilatedContext* ctx = new VerilatedContext;
	ctx->commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	VBarrelShifter* dut = new VBarrelShifter{ctx};

	VerilatedVcdC* tfp = new VerilatedVcdC;
	dut->trace(tfp, 99);
	tfp->open("dump.vcd");

	std::cout << "Test cases: " << sizeof(caseArray)/sizeof(caseArray[0]) << "\n";

	for (const auto& tc : caseArray) {
		switch (tc.m) {
    		case 0:
       			expected = (uint32_t)tc.di.u << tc.s;
				dut->data_in = tc.di.u ; dut->mode = tc.m ; dut->shamt = tc.s;
        		break;
	    	case 1:
    	    	expected = (uint32_t)tc.di.u >> tc.s;
				dut->data_in = tc.di.u ; dut->mode = tc.m ; dut->shamt = tc.s;
       			break;
			case 2:
				expected = tc.di.s >> tc.s;
				dut->data_in = tc.di.s ; dut->mode = tc.m ; dut->shamt = tc.s;
				break;
    		default:
    	    	expected = tc.di.u << tc.s;
				dut->data_in = tc.di.u ; dut->mode = tc.m ; dut->shamt = tc.s;
    	    break;
		}

		dut->eval();
	
		if (!(dut->data_out == expected)) {
			std::cout << "FAIL: expected value of " << expected << " not asserted. Received: " << dut->data_out << "\n";
			return 1;
		}
		std::cout << dut->data_out << "\n";

		tfp->dump(ctx->time()); ctx->timeInc(10);
	}
	

	dut->final();

	std::cout << "closing trace\n";
	tfp->close();
	delete dut; delete ctx;
	return 0;
}
