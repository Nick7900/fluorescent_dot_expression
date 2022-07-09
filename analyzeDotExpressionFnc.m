% Functions to analyze and quantify fluorescent dot expression from 
% RNAscope stained tissue
% Requires the Signal Processing Toolbox to use the function: findpeaks
% Code written and posted by Dr. Nick Yin Larsen, originally in July 2022.
%------------------------------------------------------------------------------------------------------------------------------------------------------
function [result] = analyzeDotExpressionFnc(IMG,RES,AREADOT)
% Sintax:
%     [result] = analyseImageFnc(rgbImage,res)
% Input:
%     rgbImage,     Input image
%     res,          Resolution of image
% Output:
%     result,   	Results saved as a struct
%% Variables
SIZE_DISK = 5; % morphological filter size
%% Convert image to grayimage
[~, ~, numberOfColorChannels] = size(IMG); % Detect number of channels
% Detect dominant channel of image
if numberOfColorChannels > 1
    % Define each channel
    red=IMG(:,:,1);
    green=IMG(:,:,2);
    blue=IMG(:,:,3);
    % Get mean intensity value
    meanIntensityRed = mean2(red);
    meanIntensityGreen = mean2(green);
    meanIntensityBlue = mean2(blue);
    
    % Define the color of the image
    if meanIntensityRed>meanIntensityGreen && meanIntensityRed>meanIntensityBlue
        color = 1;
        grayImage =IMG(:,:,color);
    elseif meanIntensityGreen>meanIntensityRed && meanIntensityGreen>meanIntensityBlue
        color = 2;
        grayImage =IMG(:,:,color);
    elseif meanIntensityBlue>meanIntensityRed && meanIntensityBlue>meanIntensityGreen
        color = 3;
        grayImage =IMG(:,:,color);
    else
        % In case there is no dominant channel
        grayImage =rgb2gray(IMG);
    end
end

%% Detect peak measures from the intensity of image
% Used to calculate the image threshold of the background
% https://se.mathworks.com/help/signal/ug/prominence.html
[counts] = imhist(grayImage);
counts(1)=0;
[~,locs] = findpeaks(counts,'MinPeakProminence',10);
lim =round((locs(1)+locs(2))/2); % Threshold is between the two peaks
%% morphological operations
SE = strel('disk',SIZE_DISK);
% Morphologically open image - erosion followed by a dilation
I_filt = imopen(grayImage,3);
% Top-hat filtering - subtracts the result from the original image
I_filt = imtophat(I_filt,SE);
% Set background values below our limit to 0 => remove a lot of noise
I_filt(I_filt<lim)=0;
% Apply Sobel filter
gradmag = imgradient(I_filt, 'Sobel');
% Calculate the local standard deviation
sdImage = stdfilt(gradmag, ones(3));
% Run binaryFnc
[overlay,binaryImage] = binaryFnc(sdImage,grayImage);
%% Watershed transformation
% Compute the distance transform of the complemented binary image,
D = -bwdist(~binaryImage);
% Force the background to be its own catchment basin,
D(~binaryImage) = -Inf;
% Compute the watershed transform.
L = watershed(D);
[coloredLabels_count,coloredLabels,a_l,bigBlob,blobMeasurements] =labelBlobFnc(L,grayImage,RES,AREADOT);
result = struct('Original',grayImage,'Image_filt',I_filt,'Circle_Image',coloredLabels_count,'Color_Image',coloredLabels,'Number_blobs',a_l,'Big_Blobs',bigBlob,'Overlay',overlay,'blobMeasurements',blobMeasurements);
end

function [overlay,binaryImage] = binaryFnc(sdImage,grayImage)
%% Binarize the gradient image, remove outliers, and create an overlay
% Sintax:
%     [srcFiles]=readFiles(FOLDER)
% Input:
%     sdImage,          Local standard deviation of image
%     grayImage,        Grayscale image
% Output:
%     overlay,          Burn the binary image into the grayscale image
%     binaryImage,      Binary image of fluorescent dot expression

% Binarize grayscale image
bw =imbinarize(sdImage);
% Fill the holes
bw2 = imfill(bw,'holes');
sizeDisk=ones(3,3);
% Morphologically close image
binaryImage = imclose(bw2,sizeDisk);
%% Remove outliers => signals with a high intensity
labeledImage = binaryImage;
% Measure properties of image regions
m = regionprops(labeledImage, grayImage, 'Area','MeanIntensity','PixelList');
T= struct2table(m); % Convert to a table

% Sort the intensity values
[intensity,idx] =sort(T.MeanIntensity);
% Only look at intensities that are regarded as outliers
intensityOutlier =intensity(intensity>mean(intensity)+3*std(intensity));
idxOutlier =idx(intensity>mean(intensity)+3*std(intensity));

% Intensities with a difference jump above 15 are regarded as outliers
posRemove =idxOutlier([0;diff(intensityOutlier)]>15);
if ~isempty(posRemove)
    posRemove = idxOutlier(find(idxOutlier==posRemove(1)):end);
    % Convert ourliers to black background
    for k = 1:size(posRemove,1)
        blob =m(posRemove(k));
        coor = blob.PixelList;
        for j=1:size(coor,1)
            binaryImage(coor(j,2),coor(j,1))=0; % overwrite binary image
        end
    end
end
% Find the perimeter of objects binary image
bw_perim = bwperim(binaryImage);
% Apply binary mask of object perimeter into the grayscale image
overlay = imoverlay(grayImage, bw_perim, [.8 .2 .3]);
end

function [coloredLabels_count,coloredLabels,a_l,bigBlob,blobMeasurements] =labelBlobFnc(L,grayImage,RES,AREADOT)
%% Binarize the gradient image, remove outliers, and create an overlay
% Sintax:
%     [coloredLabels_count,coloredLabels,a_l,bigBlob,blobMeasurements] =labelBlobFnc(L,grayImage,RES,AREADOT)
% Input:
%     L,                Watershed transformed image
%     grayImage,        Grayscale image
%     RES,              Image resolution (pixel/µm)
%     AREADOT,          Regions of fluorescent dot expression with Area
%                       (µm^2) above threshold will be counted for 2
% Output:
%     coloredLabels_count,  Region of each dot expression are colored with
%                           Text and Inserted circles
%     coloredLabels,        Region of each dot expression are colored
%     a_l,                  Number of detected fluorescent dot expression
%     bigBlob,              Indices of big fluorescent dot expression
%     blobMeasurements,     Measured properties of image regions of fluorescent dot expression
%% Variables
ARTEFACT_REMOVE=3; % Image regions below 3 pixels are removed
%% Get region properties
blobMeasurements = regionprops(L, grayImage, 'Area','PixelList','Centroid'); % use 'all' if you want every attributes
[rows, columns] = size(L);
T = struct2table(blobMeasurements); % convert the struct array to a table
% Remove very big blobs from the counting
a =T.Area;
areaSmall =find(a<=ARTEFACT_REMOVE);
% Remove detected artefacts below ARTEFACT_REMOVE
for k = 1:size(areaSmall,1)
    blob =blobMeasurements(areaSmall(k));
    coor = blob.PixelList;
    for j=1:size(coor,1)
        L(coor(j,2),coor(j,1))=1;
    end
end
% Remove artefacts from table
T(a<=ARTEFACT_REMOVE,:)=[];
% Remove big area artefact that accounts for the tissue area
[m,midx]=max(T.Area);
% Removing the field area that accounts for the whole image frame
if m>(rows*columns)*0.5
    T(midx,:)=[];
end
a =T.Area;
a_l =length(a); % length of area
% Convert measurement back to struct
blobMeasurements = table2struct(T);

%% Color the labels
% Assign each blob a different color
coloredLabels = label2rgb (L, 'jet','k', 'shuffle'); % pseudo random color labels

%% Detect dominant color for each channel
red=coloredLabels(:,:,1);
green=coloredLabels(:,:,2);
blue=coloredLabels(:,:,3);

[counts, ~] = imhist(red); % Get the counts and grayLevels values
[~, idxMaxr] = max(counts(:));
[counts, ~] = imhist(green); % Get the counts and grayLevels values
[~, idxMaxg] = max(counts(:));
[counts, ~] = imhist(blue); % Get the counts and grayLevels values
[~, idxMaxb] = max(counts(:));
% Set background color to be black
idxMaxr = idxMaxr-1;
idxMaxg = idxMaxg-1;
idxMaxb = idxMaxb-1;
%% Combine each channel
% Find pixels that are pure black - black in all 3 channels.
blackPixels = red == idxMaxr & green  == idxMaxg & blue  == idxMaxb;
% Make black color
red(blackPixels) = 0; % Black background turn to 0
green(blackPixels) = 0; % Black background turn to 0
blue(blackPixels) = 0; % Black background turn to 0
% Combining the colors together to a new image
coloredLabels = cat(3, red, green, blue);
%% Identifying big blobs and let them count for 2 instead of 1
% Find indices Areas above defined threshold for AREADOT
bigBlob =find(a>round(AREADOT*RES)); %% 22
cen = zeros(length(bigBlob),2); % matrix for centroid
if ~isempty(bigBlob)
    for i = 1:numel(bigBlob)
        a(a_l+i)=1;
        cen(i,1) =blobMeasurements(bigBlob(i)).Centroid(1);
        cen(i,2) =blobMeasurements(bigBlob(i)).Centroid(2);
    end
end
%% Save labelled image with blobs and counts
% Creating a struct element for the image
S = struct('Image',[]);
%  Adding a white circle to each big blobs that are detected
if ~isempty(bigBlob)>0
    for i = 1:numel(bigBlob)
        a(a_l+i)=1; % add the extra counted blob
        if i == 1 && numel(bigBlob)==1
            S.Image = insertShape(coloredLabels,'circle',[cen(i,1),cen(i,2),1],'Color',{'white'},'LineWidth',2);
        elseif i == 1    % if only there is 1 blob, save S
            shape_image = insertShape(coloredLabels,'circle',[cen(i,1),cen(i,2),1],'Color',{'white'},'LineWidth',2);
        else
            shape_image = insertShape(shape_image,'circle',[cen(i,1),cen(i,2),1],'Color',{'white'},'LineWidth',2);
            S.Image = shape_image; %shape of circle
        end
        
    end
    % Number of objects
    conf_val = [a_l length(bigBlob)];
    text_str = ['Number of points: ',num2str(conf_val(1)), ' + ',num2str(conf_val(2))];
    % Insert text to the colorimage
    position = [1 1];
    box_color = {'yellow'};
    coloredLabels_text = insertText(S(end).Image,position,text_str,'FontSize',18,'BoxColor',...
        box_color,'BoxOpacity',0.4,'TextColor','white');
    S(end).Image =coloredLabels_text;
else
    conf_val = [a_l length(bigBlob)];
    text_str = ['Number of points: ',num2str(conf_val(1)), ' + ',num2str(conf_val(2))];
    % Insert text to the colorimage
    position = [1 1];
    box_color = {'yellow'};
    coloredLabels_text = insertText(coloredLabels,position,text_str,'FontSize',18,'BoxColor',...
        box_color,'BoxOpacity',0.4,'TextColor','white');
    S.Image =coloredLabels_text; % Text
end
coloredLabels_count = S.Image; % color label image with count
end
