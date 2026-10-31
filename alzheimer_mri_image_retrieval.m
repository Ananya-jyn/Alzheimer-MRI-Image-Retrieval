clc;
clear;
close all;

disp('ALZHEIMER MRI IMAGE RETRIEVAL');
disp('-----------------------------');

% STEP 1: Select Original dataset folder
datasetFolder = uigetdir('C:\Users\ECE LAB\Desktop', ...
    'Select ORIGINAL dataset folder');

if isequal(datasetFolder, 0)
    error('Please select the dataset folder and run again.');
end

if exist(datasetFolder, 'dir') ~= 7
    error('The selected dataset folder does not exist.');
end

imds = imageDatastore(datasetFolder, ...
    'IncludeSubfolders', true);

if isempty(imds.Files)
    error('No supported image files found in the selected folder.');
end

fprintf('Images found: %d\n', numel(imds.Files));

% STEP 2: Load images from subfolders
imds = imageDatastore(datasetFolder, ...
    'IncludeSubfolders', true);

numImages = numel(imds.Files);

if numImages < 2
    error('Please select a folder containing at least 2 images.');
end

fprintf('Total images found: %d\n', numImages);

% STEP 3: Extract GLCM features
features = zeros(numImages, 4);

for i = 1:numImages

    I = imread(imds.Files{i});

    % Convert RGB image to grayscale
    if ndims(I) == 3
        I = rgb2gray(I);
    end

    % Resize image
    I = imresize(I, [128 128]);

    % Convert to uint8 grayscale image
    I = im2uint8(I);

    % Calculate GLCM
    G = graycomatrix(I, ...
        'NumLevels', 8, ...
        'GrayLimits', [0 255], ...
        'Offset', [0 1], ...
        'Symmetric', true);

    % Extract texture properties
    P = graycoprops(G, ...
        {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});

    features(i, :) = [P.Contrast, ...
        P.Correlation, ...
        P.Energy, ...
        P.Homogeneity];

    if mod(i, 50) == 0
        fprintf('Processed %d of %d images\n', i, numImages);
    end
end

disp('Feature extraction completed.');

% STEP 4: Normalize feature values
featureMean = mean(features, 1);
featureStd = std(features, 0, 1);
featureStd(featureStd == 0) = 1;

normalizedFeatures = bsxfun(@rdivide, ...
    bsxfun(@minus, features, featureMean), featureStd);

% STEP 5: Select query MRI image
[queryFile, queryPath] = uigetfile( ...
    {'*.jpg;*.jpeg;*.png;*.bmp;*.tif', ...
    'MRI Images (*.jpg, *.jpeg, *.png, *.bmp, *.tif)'}, ...
    'Select a query MRI image');

if isequal(queryFile, 0)
    disp('Query image not selected.');
    return;
end

queryImage = imread(fullfile(queryPath, queryFile));

% Convert query image to grayscale
if ndims(queryImage) == 3
    queryImage = rgb2gray(queryImage);
end

queryImage = imresize(queryImage, [128 128]);
queryImage = im2uint8(queryImage);

% Extract query image GLCM features
Gq = graycomatrix(queryImage, ...
    'NumLevels', 8, ...
    'GrayLimits', [0 255], ...
    'Offset', [0 1], ...
    'Symmetric', true);

Pq = graycoprops(Gq, ...
    {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});

queryFeatures = [Pq.Contrast, ...
    Pq.Correlation, ...
    Pq.Energy, ...
    Pq.Homogeneity];

% Normalize query features
normalizedQuery = bsxfun(@rdivide, ...
    bsxfun(@minus, queryFeatures, featureMean), ...
    featureStd);

% STEP 6: Calculate Euclidean distances
difference = bsxfun(@minus, normalizedFeatures, normalizedQuery);
distances = sqrt(sum(difference.^2, 2));

% STEP 7: Rank images by similarity
[sortedDistances, sortedIndices] = sort(distances, 'ascend');

topK = min(5, numImages);
topIndices = sortedIndices(1:topK);

% STEP 8: Display query and retrieved images
figure('Name', 'Alzheimer MRI Image Retrieval');

subplot(2, 3, 1);
imshow(queryImage);
title('Query MRI Image');

for k = 1:topK

    retrievedImage = imread(imds.Files{topIndices(k)});

    subplot(2, 3, k + 1);
    imshow(retrievedImage);

    title(sprintf('Result %d | Dist: %.3f', ...
        k, sortedDistances(k)));
end

disp(' ');
disp('Retrieved image file names:');

for k = 1:topK
    fprintf('%d. %s | Distance = %.4f\n', ...
        k, imds.Files{topIndices(k)}, sortedDistances(k));
end

disp('Retrieval completed successfully.');
