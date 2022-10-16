% Pipeline to visualize, analyze and quantify fluorescent dot expression from
% RNAscope stained tissue
% Requires the Signal Processing Toolbox to use the function: findpeaks
% Code written and posted by Dr. Nick Yin Larsen, originally in October 2022.
%------------------------------------------------------------------------------------------------------------------------------------------------------
% Define variables
IMGFOLDER = 'High Background - off';
EXCELRESULTS = 'Data_number.xlsx'; % Dot expression results
IMGTYPE = 'tif';
RES =6.2; % Resolution: X pixel/µm
AREADOT =16;  %  Regions of fluorescent dot expression with Area
%  (µm^2) above threshold will be counted for 2 instead of 1
VISUALIZE = 0; % Dont visualize results
SUPERIMPOSED_IMG = 1; % Superimposed images (1 save, 0 do not save)

%% Read all files in the folder
[srcFiles]=readFiles(IMGFOLDER,IMGTYPE); % Read the files
I_S(length(srcFiles)) = struct('Img',[],'Results',[],'Name',[]); % Create struct of each image
% Run the analysis for each image
for i = 1 : length(srcFiles)
    disp(['Process image nr.',num2str(i)])
    filename = strcat(IMGFOLDER,'/',srcFiles(i).name); % Directions to data
    I_S(i).Img =imread(filename); % Read the image
    I_S(i).Results = analyzeDotExpressionFnc(I_S(i).Img,RES,AREADOT); % Run the analysis file
    [~,name] = fileparts([srcFiles(i).folder,'\',srcFiles(i).name]); % Name of file
    I_S(i).Name = name; % save name of file
    % Creating the folder overlay
    folder=('Overlay');
    createFolders(folder)
    imwrite(I_S(i).Results.Overlay, [folder,'/',name,'_overlay.',IMGTYPE],IMGTYPE); % Saving overlay images to the folder

    folder=('Binary_Img');
    createFolders(folder)
    imwrite(I_S(i).Results.Binary_Image, [folder,'/',name,'_binary.',IMGTYPE],IMGTYPE); % Saving overlay images to the folder

    % Creating the folder number
    folder=('Number_count');
    createFolders(folder)
    imwrite(I_S(i).Results.Circle_Image, [folder,'/',name,'_number.',IMGTYPE],IMGTYPE); % Saving number count images to the folder
    % Save superimposed image
    superImposedImg(SUPERIMPOSED_IMG,I_S(i),name)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save  number of points from result struct%%%%
img_name = cell(length(I_S),1);
number_dots = zeros(length(I_S),1);
number_big_dots = zeros(length(I_S),1);
img_threshold = zeros(length(I_S),1);

for i = 1:length(I_S)
    number_dots(i,1) = I_S(i).Results.Number_blobs; % Number of detected blobs
    number_big_dots(i,1) = length(I_S(i).Results.Big_Blobs); % Number of big blobs
    img_threshold(i,1) = I_S(i).Results.lim; % Threshold limitation
    img_name{i} =I_S(i).Name;
end
% Generate table
data_table = table(img_name,number_dots,number_big_dots,img_threshold);
writetable(data_table,'Data_number.xlsx')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Functions %%%%
function [srcFiles]=readFiles(IMGFOLDER,IMGTYPE)
%% Read files
% Sintax:
%     [srcFiles]=readFiles(FOLDER)
% Input:
%     FOLDER,     Folder location of images
% Output:
%     srcFiles,   Source locations of files
srcFiles = dir([IMGFOLDER,'/*.',IMGTYPE]);  % Get path to read files
if isempty(srcFiles)
    disp('Choose which Detail folder to analyse')
    directory =uigetdir;
    srcFiles =dir([directory,'/*.',IMGTYPE]);
end

end


function createFolders(FOLDER)
%% Create folders to save results
% Sintax:
%     createFolders(FOLDER)
% Input:
%     FOLDER,     Folder location of images
if ~exist(FOLDER, 'dir')
    mkdir(FOLDER);
end
end

function superImposedImg(SUPERIMPOSED_IMG,I_S,name)
%% Save the super imposed image of the original image and the detected dots
% Sintax:
%     superImposedImg(SUPERIMPOSED_IMG,I_S,name)
% Input:
%     SUPERIMPOSED_IMG,     Define if you want to save image (1 save, 0 do not save)
%     I_S,                  Image
%     name,                 name of image
if SUPERIMPOSED_IMG ==1
    folder=('Superimposed');
    createFolders(folder)

    figure('visible', 'off');
    imshow(I_S.Img)
    axis tight
    hold on
    himage= imshow(I_S.Results.Color_Image);
    himage.AlphaData = 0.35;
    saveas(gcf,[folder,'/',name,'_super.tif'],'tif')
end
end