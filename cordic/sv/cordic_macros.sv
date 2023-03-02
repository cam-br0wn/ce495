
// quantization
`define BITS                14
`define QUANT_VAL           (1 << `BITS)
`define QUANTIZE_F(f)       int'((shortreal'(f) * shortreal'(`QUANT_VAL)))
`define QUANTIZE_I(i)       int'(int'(i) * int'(`QUANT_VAL))
`define DEQUANTIZE_I(i)     int'(int'(i) / int'(`QUANT_VAL))
`define DEQUANTIZE_F(i)     shortreal'(shortreal'(i) / shortreal'(`QUANT_VAL))

// constants
`define K           1.646760258121066
`define M_PI        3.141592653589793
`define CORDIC_1K   `QUANTIZE_F(1/`K)   
`define PI          `QUANTIZE_F(`M_PI)
`define TWO_PI      `QUANTIZE_F(`M_PI*2.0) 
`define HALF_PI     `QUANTIZE_F(`M_PI/2.0)
