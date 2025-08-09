%%

clear; clc; close force all;

%%

load('MarioRGB.mat');
gray_img = flipud(rgb2gray(RGB));

% Get image size
[n_rows, n_cols] = size(gray_img);

% Pad the grayscale image
padded_image = padarray(gray_img, [1, 1], 0, 'both');

% Define kernel
kernel = int16([0 -1 0; -1 9 -1; 0 -1 0]);

% Initialize convolved matrix
convolved_matrix = zeros(n_rows, n_cols, 'int16');

% Manual convolution
for i = 1:n_rows
    for j = 1:n_cols
        patch = int16(padded_image(i:i+2, j:j+2));
        convolved_matrix(i, j) = sum(sum(patch .* kernel));
    end
end

convolved_matrix = single(convolved_matrix);

% % Normalize convolved_matrix to [0, 1]
% conv_min = double(min(convolved_matrix(:)));
% conv_max = double(max(convolved_matrix(:)));
% normalized_convolved = (double(convolved_matrix) - conv_min) / (conv_max - conv_min);
% normalized_convolved(isnan(normalized_convolved)) = 0;
% normalized_convolved = normalized_convolved - 0.5;

%% Grid setup

% ----- Instance Normalization -----
% Parameters (can be learnable in a real NN)
gamma = 1; 
beta = 0;

% Compute mean and std for the current image
mu = mean(convolved_matrix(:));
sigma = std(convolved_matrix(:));

% Normalize
instance_norm_matrix = (convolved_matrix - mu) / (sigma + eps);

% Apply scale and shift
instance_norm_matrix = gamma * instance_norm_matrix + beta;

figure;
subplot(1,2,1);
histogram(convolved_matrix(:), 50, 'FaceColor', 'b', 'EdgeColor', 'none');
title('Before Instance Norm');
xlabel('Pixel Value');
ylabel('Frequency');
grid on;

subplot(1,2,2);
histogram(instance_norm_matrix(:), 50, 'FaceColor', 'g', 'EdgeColor', 'none');
title('After Instance Norm');
xlabel('Pixel Value');
ylabel('Frequency');
grid on;


%%
