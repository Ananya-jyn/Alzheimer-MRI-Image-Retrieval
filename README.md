# Alzheimer MRI Image Retrieval

## Project Overview
This project focuses on retrieving similar Alzheimer's brain MRI images using image processing techniques in MATLAB.

The system extracts texture features from MRI images using the Gray-Level Co-occurrence Matrix (GLCM) and compares them using Euclidean distance to identify the most similar images.

## Technologies Used
- MATLAB
- Image Processing Toolbox
- GLCM (Gray-Level Co-occurrence Matrix)
- Euclidean Distance

## Methodology
1. Load the MRI image dataset.
2. Preprocess images by converting them to grayscale and resizing.
3. Extract GLCM texture features.
4. Normalize the extracted features.
5. Select a query image.
6. Calculate Euclidean distance between the query image and dataset images.
7. Display the top 5 similar images.

## Project Output
The system displays the query image and the five most similar MRI images based on feature similarity.

## Project Limitation
This project performs image retrieval based on similarity. It does not independently diagnose Alzheimer's disease.

## Files
- `alzheimer_mri_image_retrieval.m` – MATLAB source code
- `OUTPUT.jpeg` – Project output image

## Author
Ananya Jyn
