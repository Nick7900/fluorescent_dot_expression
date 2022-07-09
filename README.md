# Quantify fluorescent dot expression 
Demonstration of how to analyze the total fluorescent dot expression of the delineated green fluorescent Oprk1 dot images.
- We have created custom MATLAB scrips to visualize, analyze and quantify fluorescent dot expression from RNAscope stained tissue

If using this code or dataset, please cite:

Krogsbaek M, Larsen NY, Landau A, Sanchez C, Lin J and Nyengaard JR. "Spatial quantification of single cell mRNA and ligand binding of the kappa opioid receptor in rat hypothalamus".

Note the paper is not published yet.

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
2. pipelineDotExpression.m is the main file and you need to specify the image resolution in pixels/µm and set an Area (m2) threshold for determining when to count two expressions instead of one.
3. When the code is executed, images (Number Count, Overlay and Superimposed) and an Excel file that counts the number of dot expressions for each image will be exported.

## Example
AutoCUTSAnalysis includes scripts implemented on a test collection of 50 images(will be available after publication of article) that involve the following steps:
Align sections
Crop aligned stack where only tissue appears
Using the UNetDense architecture to segment cells, the region of interest could then be defined based on a density map of centroids.
Filtering small cells away with k-means and reconstruct neurons in 3D.

![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_frame](https://user-images.githubusercontent.com/70948370/178108437-d929f0c7-44a9-4e66-afda-ecac4c60a429.jpg)



![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_crop](https://user-images.githubusercontent.com/70948370/178103656-6c2a635a-7cc3-4cbb-b9f8-5621f90aed5f.png)
![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_crop_overlay](https://user-images.githubusercontent.com/70948370/178103662-d6172ad2-4e65-4d27-a303-9a5987d291df.png)
![Brain 03_OPRK1, sect 10, L5 x63 left hypo SI_crop_number](https://user-images.githubusercontent.com/70948370/178103658-9b12c4fb-bfc6-4d40-8c2f-386e06994ac7.png)
