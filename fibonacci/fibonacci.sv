module fibonacci(
  input logic clk, 
  input logic reset,
  input logic [15:0] din,
  input logic start,
  output logic [15:0] dout,
  output logic done );

  // TODO: Add local logic signals
  enum logic [1:0] {init, add, stop} state, next_state;
  logic [15:0] val_a, val_b;
  logic [4:0] count;
  logic done_c;

  always_ff @(posedge clk, posedge reset)
  begin
    if ( reset == 1'b1 ) begin
      // internal signals
      state <= init;
      val_a <= 'b1;
      val_b <= 'b0;
      count <= 'b0;
      // pins
      done <= 'b0;
      dout <= 'b0;
    end else begin
      // internal signals
      state <= next_state;
      val_a <= val_a + val_b;
      val_b <= val_a;
      count <= count + 1;
      // pins
      done <= done_c;
      dout <= val_a + val_b;
    end
  end

  always_comb 
  begin
    done_c = (count + 2 == din);
    case (state)
      init:
        next_state = start ? add : init;
      add:
        next_state = done_c ? stop : add;
      stop:
        next_state = reset ? init : stop;  
    endcase
  end
endmodule