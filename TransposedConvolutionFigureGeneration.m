%%

clear; clc; close force all;

%% Load and prepare image

load('MarioRGB.mat');
gray_img = flipud(rgb2gray(RGB));

% Get image size
[n_rows, n_cols] = size(gray_img);

% Define upsampling factor (stride in transposed conv)
stride = 2;

% Define kernel
kernel = int16([0 -1 0; -1 9 -1; 0 -1 0]);

% Step 1: Upsample by inserting zeros between pixels
upsampled_rows = (n_rows - 1) * stride + 1;
upsampled_cols = (n_cols - 1) * stride + 1;
upsampled_image = zeros(upsampled_rows, upsampled_cols, 'int16');

for i = 1:n_rows
    for j = 1:n_cols
        upsampled_image(1 + (i-1)*stride, 1 + (j-1)*stride) = int16(gray_img(i, j));
    end
end

% Step 2: Pad upsampled image for convolution
padded_image = padarray(upsampled_image, [1, 1], 0, 'both');

% Step 3: Convolution after upsampling
out_rows = size(upsampled_image,1);
out_cols = size(upsampled_image,2);
transposed_conv_matrix = zeros(out_rows, out_cols, 'int16');

for i = 1:out_rows
    for j = 1:out_cols
        patch = int16(padded_image(i:i+2, j:j+2));
        transposed_conv_matrix(i, j) = sum(sum(patch .* kernel));
    end
end

% Normalize for display
conv_min = double(min(transposed_conv_matrix(:)));
conv_max = double(max(transposed_conv_matrix(:)));
normalized_transposed = (double(transposed_conv_matrix) - conv_min) / (conv_max - conv_min);
normalized_transposed(isnan(normalized_transposed)) = 0;
normalized_transposed = normalized_transposed - 0.5;

%% Grid setup

cell_size = 5; % Smaller because output is larger
gap = 20;

left_grid_x = 0;
right_grid_x = upsampled_cols * cell_size + gap;

figure('Color', 'k');
axis equal off
set(gcf, 'Position', [100, 100, 2 * upsampled_cols * cell_size + 200, upsampled_rows * cell_size + 100]);

% Draw left grid (original grayscale)
for row = 1:n_rows
    for col = 1:n_cols
        val = double(gray_img(row, col)) / 255 - 0.5;
        rectangle('Position', [(col - 1) * cell_size, (row - 1) * cell_size, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 0.5, ...
                  'FaceColor', 0.5 - [val val val]);
    end
end

% Draw right grid (after transposed convolution)
for row = 1:out_rows
    for col = 1:out_cols
        val_after = normalized_transposed(row, col);
        rectangle('Position', [right_grid_x + (col - 1) * cell_size, (row - 1) * cell_size, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 0.5, ...
                  'FaceColor', 0.5 - [val_after val_after val_after]);
    end
end

%%