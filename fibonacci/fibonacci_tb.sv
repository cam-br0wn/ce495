`timescale 1ns/1ns

module fibonacci_tb;

	localparam DATA_WIDTH = 32;
	localparam ADDR_WIDTH = 10;
	localparam VECTOR_SIZE = 64;
	localparam CLOCK_PERIOD = 10;

  logic clk; 
  logic reset = 1'b0;
  logic [15:0] din = 16'h0;
  logic start = 1'b0;
  logic [15:0] dout;
  logic done;

  // instantiate your design
  fibonacci fib(clk, reset, din, start, dout, done);

  // clock process
	always begin
		#(CLOCK_PERIOD/2) clk = 1'b1;
		#(CLOCK_PERIOD/2) clk = 1'b0;
	end

  initial
  begin

	time start_time, end_time;
	start_time = $time;
	$display("@ %0t: Beginning simulation...", start_time);
	// Reset
	#0 reset = 0;
	#10 reset = 1;
	#10 reset = 0;
	
	/* ------------- Input of 5 ------------- */
	// Inputs into module/ Assert start
	#10;
	din = 16'd5;
	start = 1'b1;
	#10 start = 1'b0;
	
	// Wait until calculation is done	
	#10 wait (done == 1'b1);

	// Display Result
	$display("-----------------------------------------");
	$display("Input: %d", din);
	if (dout === 5)
	    $display("CORRECT RESULT: %d, GOOD JOB!", dout);
	else
	    $display("INCORRECT RESULT: %d, SHOULD BE: 5", dout);


	/* ----------------------
	   TEST MORE INPUTS HERE
	   ---------------------
	*/

	// Reset
	#0 reset = 0;
	#10 reset = 1;
	#10 reset = 0;
	
	/* ------------- Input of 8 ------------- */
	// Inputs into module/ Assert start
	#10;
	din = 16'd6;
	start = 1'b1;
	#10 start = 1'b0;
	
	// Wait until calculation is done	
	#10 wait (done == 1'b1);

	// Display Result
	$display("-----------------------------------------");
	$display("Input: %d", din);
	if (dout === 8)
	    $display("CORRECT RESULT: %d, GOOD JOB!", dout);
	else
	    $display("INCORRECT RESULT: %d, SHOULD BE: 8", dout);

	// Reset
	#0 reset = 0;
	#10 reset = 1;
	#10 reset = 0;
	
	/* ------------- Input of 12 ------------- */
	// Inputs into module/ Assert start
	#10;
	din = 16'd12;
	start = 1'b1;
	#10 start = 1'b0;
	
	// Wait until calculation is done	
	#10 wait (done == 1'b1);

	// Display Result
	$display("-----------------------------------------");
	$display("Input: %d", din);
	if (dout === 144)
	    $display("CORRECT RESULT: %d, GOOD JOB!", dout);
	else
	    $display("INCORRECT RESULT: %d, SHOULD BE: 12", dout);

    // Done
	#10;
	end_time = $time;
	$display("@ %0t: Simulation completed.", end_time);
	$display("Total simulation cycle count: %0d",
	(end_time-start_time)/CLOCK_PERIOD);
	$stop;

  end
endmodule
