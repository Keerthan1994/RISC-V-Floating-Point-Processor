all: 
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+CORNERCASES +define+RANDCASES

cornercases:
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+CORNERCASES

randcases:
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+RANDCASES

debug: 
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+DEBUG +define+CORNERCASES +define+RANDCASES

sim_add:
	vsim -c top +OP=ADD

sim_sub:
	vsim -c top +OP=SUB

sim_div:
	vsim -c top +OP=DIV -suppress 8630 -suppress 8604

sim_mul:
	vsim -c top +OP=MUL

sim_all:
	vsim -c top +OP=ALL