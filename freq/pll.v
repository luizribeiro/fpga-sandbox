/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        48.000 MHz
 * Requested output frequency:  150.000 MHz
 * Achieved output frequency:   150.000 MHz
 */

module pll(
	input  clock_in,
	output clock_out,
	output locked
	);

SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0001),		// DIVR =  1
		.DIVF(7'b0011000),	// DIVF = 24
		.DIVQ(3'b010),		// DIVQ =  2
		.FILTER_RANGE(3'b010)	// FILTER_RANGE = 2
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(clock_out)
		);

endmodule
