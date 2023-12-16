Image compression plays a pivotal role in addressing the ever-growing demand for efficient data storage, transmission, and processing. As digital content continues 
to proliferate across various platforms such as social media, the volume of images being shared and stored has skyrocketed. Image compression technology 
is crucial in reducing the size of these files without significant loss of visual quality, enabling quicker data transfer and minimizing the strain on storage infrastructure. 
This not only facilitates faster upload and download speeds but also optimizes bandwidth usage, making it indispensable for online communication, streaming services, 
and mobile applications. Additionally, since image compression is so common, it is extremely beneficial to have hardware that can accelerate this compression. 
  In particular, JPEG is one of the most widely used image formats in the world, so the compression of JPEG images is a very important process in today’s
world. For our project, we will implement the following critical components used in JPEG and other image compression/decompression algorithms using SystemVerilog:

* Transformation of the data stream into uncorrelated samples using the 2D
discrete cosine transform (DCT)
* Quantization and rounding of the transform coefficients
* De-quantization of transform coefficients
* Transformation of the de-quantized coefficients to proper image data using
the inverse discrete cosine transform (IDCT)

Here is the end to end process for getting the reconstructed image out of our hardware design to allow the results to be reproduced (requires vivado or another form of running verilog testbenches)

* Install the python CV2 library (pip install opencv-python) and numpy

* First, run the mem_gen.py python script to generate all the necessary memory files in the right format, so that we can load the correct data into the design. This script will generate memory files for the input image data,
  the fixed point cosine values, and the rounded quantization matrix shift values.

* Second, add the generated memory files to your vivado project or the correct directory for the testbench to find the files. Run the top level compressor testbench, compressor_top_tb.sv in Vivado. This performs the DCT and
  quantization steps on the input image and writes the quantized coefficients to its own output memory file. Simulation takes ~1 hour.

* Third, run the top level decompressor testbench, decompressor_top_tb.sv in Vivado. This testbench reads in the values that were output to the mem file from the previous step, performs dequantization and IDCT steps, 
  and writes the reconstructed grayscale image data to its own memory file. Simulation takes ~1 hour.

* Fourth, run the process_rtl_output.py python script. This script converts the raw output from the memory file to an appropriately shaped numpy array, and then uses the CV2 library to create the JPEG image based on the numpy array.
  Open this JPEG image to see the reconstruction! This script also prints the MSE between the hardware image reconstruction and the raw image. The main.py script performs software compression/decompression and prints the MSE and time
  taken for the different steps.

To briefly explain the images in the image_data folder, image_data/raw/river.jpg is the raw grayscale image, image_data/decompressed/river.jpg is the full software reconstruction using the normal quantization matrix, 
image_data/decompressed/river_rounded.jpg is the full software reconstruction using the rounded quantization matrix that we use in hardware, image_data/decompressed/hw/river.jpg is a reconstruction resulting from compression in hardware
and decompression in software, and image_data/decompressed/hw/river_full_hw.jpg is the reconstruction that results from both hardware compression and decompression.

The full final report is located in the repo. It is called EE274_Final_Report.pdf.
