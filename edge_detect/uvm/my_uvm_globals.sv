`ifndef __GLOBALS__
`define __GLOBALS__

// UVM Globals
localparam string IMG_IN_NAME  = "/home/ckb4640/ce495/edge_detect/images/copper_720_540.bmp";
localparam string IMG_OUT_NAME = "/home/ckb4640/ce495/edge_detect/images/output.bmp";
localparam string IMG_CMP_NAME = "/home/ckb4640/ce495/edge_detect/source/stage2_sobel.bmp";
localparam int IMG_WIDTH = 720;
localparam int IMG_HEIGHT = 540;
localparam int BMP_HEADER_SIZE = 54;
localparam int BYTES_PER_PIXEL = 3;
localparam int BMP_DATA_SIZE = (IMG_WIDTH * IMG_HEIGHT * BYTES_PER_PIXEL);
localparam int CLOCK_PERIOD = 10;

`endif
