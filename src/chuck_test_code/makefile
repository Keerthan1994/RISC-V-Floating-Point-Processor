all: 
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+CORNERCASES +define+RANDCASES

cornercases:
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+CORNERCASES

randcases:
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+RANDCASES

debug: 
	vlog design/*.sv verification/add_sub_top_tb.sv -lint=full +define+DEBUG +define+CORNERCASES +define+RANDCASES