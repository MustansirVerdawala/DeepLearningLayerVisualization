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

% Normalize convolved_matrix to [0, 1]
conv_min = double(min(convolved_matrix(:)));
conv_max = double(max(convolved_matrix(:)));
normalized_convolved = (double(convolved_matrix) - conv_min) / (conv_max - conv_min);
normalized_convolved(isnan(normalized_convolved)) = 0;
normalized_convolved = normalized_convolved - 0.5;

%% Grid setup

cell_size = 10;
gap = 20;

left_grid_x = 0;
right_grid_x = n_cols * cell_size + gap;

figure('Color', 'k');
axis equal off
set(gcf, 'Position', [100, 100, 2 * n_cols * cell_size + 200, n_rows * cell_size + 100]);

% Draw left grid (convolved input)
for row = 1:n_rows
    for col = 1:n_cols
        val = normalized_convolved(row, col);
        rectangle('Position', [(col - 1) * cell_size, (row - 1) * cell_size, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, ...
                  'FaceColor', 0.5 - [val val val]);
    end
end

relu_matrix = min(normalized_convolved, 0);

for row = 1:n_rows
    for col = 1:n_cols
        val_after = relu_matrix(row, col);

        rectangle('Position', [right_grid_x + (col - 1) * cell_size, (row - 1) * cell_size, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, ...
                  'FaceColor', 0-[val_after val_after val_after]*2);
    end
end


%%