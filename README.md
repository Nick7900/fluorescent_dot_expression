# Quantify fluorescent dot expression 
Demonstration of how to analyze the total fluorescent dot expression of the delineated green fluorescent Oprk1 dot images.
- We have created custom MATLAB scrips to visualize, analyze and quantify fluorescent dot expression from RNAscope stained tissue

If using this code or dataset, please cite:

Krogsbaek M, Larsen NY, Landau A, Sanchez C, Lin J and Nyengaard JR. "Spatial quantification of single cell mRNA and ligand binding of the kappa opioid receptor in rat hypothalamus".

[![DOI](https://zenodo.org/badge/6964300.svg)](https://zenodo.org/badge/latestdoi/6964300)

**Note the paper is not published yet.**

## Requirements 
Before starting, you will need the following:

- Install [MATLAB](https://www.mathworks.com/downloads/).
- Install [Signal processing toolbox](https://se.mathworks.com/products/signal.html) before running the code. 

## Code Guideline
In this repository, we demonstrate how to analyze tissue from the hypothalamus of a rat that has been stained with RNAscope.
The code is generic and be used on any tissue to detect fluorescent dot expression.
Two images are included in this demonstration and are located in the Images folder.

### How to run the code
1. Both MATLAB files (PipelineDotExpression.m and analyzeDotExpressionFnc.m) should be placed just outside the Images folder before running the code.
2. pipelineDotExpression.m is the main file and you need to specify the image resolution in pixels/µm and set an Area (µm^2) threshold for determining when to count two expressions instead of one.
  - In our case the values are set to be 6.2 pixels/µm and 16 µm^2 based on pipeline optimization images
3. When the code is executed, images (Number Count, Overlay and Superimposed) and an Excel file that counts the number of dot expressions for each image will be exported.

## Visualize output Example
In this example, the code is being used on the image "Brain 03 OPRK1, sect 10, L5 x 63 left hypo SI." 
The output that we can see is from a zoomed-in region inside the red frame.
![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_frame](https://user-images.githubusercontent.com/70948370/178108437-d929f0c7-44a9-4e66-afda-ecac4c60a429.jpg)


**Image is magnified inside the red frame.**

![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_crop](https://user-images.githubusercontent.com/70948370/178103656-6c2a635a-7cc3-4cbb-b9f8-5621f90aed5f.png)

**Output of the overlay image.** 

In the overlay image, the background is a grayscale image, and red lines are used to highlight the boundaries of each fluorescence dot expression.

![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_crop_overlay](https://user-images.githubusercontent.com/70948370/178103662-d6172ad2-4e65-4d27-a303-9a5987d291df.png)

**Fluorescence dot expression has been quantitatively counted.**

Notice: White circles have been used to highlight areas that are greater than 16 µm^2, and these areas count as 2 dot expressions instead of 1 dot expression.

![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_crop_number](https://user-images.githubusercontent.com/70948370/178103658-9b12c4fb-bfc6-4d40-8c2f-386e06994ac7.png)

## Contact
If you have any questions or suggestions, you can reach Nick via e-mail at nylarsen@clin.au.dk or Maiken via e-mail at mkm@clin.au.dk.
