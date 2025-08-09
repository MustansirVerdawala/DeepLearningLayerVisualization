%%

clear; clc; close force all;

%%

load('MarioRGB.mat');
RGB = flipud(RGB);

% Convert to grayscale and pad accordingly for 5x5 receptive field
gray_img = rgb2gray(RGB);
[n_rows, n_cols] = size(gray_img);
dilation = 2;
pad_size = 1 * dilation; % for 5x5 kernel with dilation=2

padded_matrix = padarray(double(gray_img), [pad_size pad_size], 0, 'both');

% Define 3x3 kernel weights (edge enhance)
kernel_3x3 = [0 -1 0; -1 9 -1; 0 -1 0];

% Construct 5x5 atrous kernel by inserting zeros between weights
kernel_5x5 = zeros(5,5);
kernel_5x5(1,1) = kernel_3x3(1,1);
kernel_5x5(1,3) = kernel_3x3(1,2);
kernel_5x5(1,5) = kernel_3x3(1,3);
kernel_5x5(3,1) = kernel_3x3(2,1);
kernel_5x5(3,3) = kernel_3x3(2,2);
kernel_5x5(3,5) = kernel_3x3(2,3);
kernel_5x5(5,1) = kernel_3x3(3,1);
kernel_5x5(5,3) = kernel_3x3(3,2);
kernel_5x5(5,5) = kernel_3x3(3,3);

% Initialize convolved matrix
convolved_matrix = zeros(n_rows, n_cols);

%%

cell_size = 50;
gap = 500;
left_grid_x = 0;
right_grid_x = n_cols * cell_size + gap;

figure('Color', 'k');
axis equal;
set(gcf, 'Position', [0, 0, right_grid_x + n_cols*cell_size + 200, n_rows*cell_size + 100]);
hold on;
axis off;

% Draw left grid (original RGB image)
for row = 1:n_rows
    for col = 1:n_cols
        x_start = left_grid_x + (col - 1)*cell_size;
        y_start = (row - 1)*cell_size;
        color = double(squeeze(RGB(row, col, :)))' / 255;
        rectangle('Position', [x_start, y_start, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', color);
    end
end

% Draw right grid (initially black)
for row = 1:n_rows
    for col = 1:n_cols
        x_start = right_grid_x + (col - 1)*cell_size;
        y_start = (row - 1)*cell_size;
        rectangle('Position', [x_start, y_start, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', [0 0 0]);
    end
end

% Initialize kernel rectangle on left grid (5x5 kernel)
h_kernel = rectangle('Position', [0, 0, 5*cell_size, 5*cell_size], ...
                     'EdgeColor', 'w', 'LineWidth', 4);

% Precompute min/max for normalization after convolution
conv_values = [];

pause(3);

for i = n_rows:-1:1
    for j = 1:n_cols
        % Calculate the 5x5 patch coordinates with dilation spacing
        patch = zeros(5,5);
        for ki = 1:5
            for kj = 1:5
                patch(ki, kj) = padded_matrix(i-1+ki, j-1+kj);
            end
        end

        % Compute atrous convolution: sum of element-wise multiplication
        conv_val = sum(sum(patch .* kernel_5x5));
        convolved_matrix(i,j) = conv_val;
        conv_values(end+1) = conv_val;

        % Normalize conv_val so far for visualization
        conv_min = min(conv_values);
        conv_max = max(conv_values);
        conv_val_norm = (conv_val - conv_min) / (conv_max - conv_min);
        conv_val_norm = max(0, min(1, conv_val_norm)); % clamp 0-1

        % Color for right grid (grayscale)
        color = [conv_val_norm, conv_val_norm, conv_val_norm];

        % Draw on right grid with highlight border briefly
        x_start_right = right_grid_x + (j - 1) * cell_size;
        y_start_right = (i - 1) * cell_size;

        h_highlight = rectangle('Position', [x_start_right, y_start_right, cell_size, cell_size], ...
                                'EdgeColor', 'y', 'LineWidth', 4, 'FaceColor', 1 - color);
        pause(0.00001);

        % Replace highlight with normal border rectangle
        delete(h_highlight);
        rectangle('Position', [x_start_right, y_start_right, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', 1 - color);

        % Update kernel position on left grid (with dilation spacing)
        x_kernel = left_grid_x + (j - 1)*cell_size - dilation*cell_size;
        y_kernel = (i - 1)*cell_size - dilation*cell_size;
        set(h_kernel, 'Position', [x_kernel, y_kernel, 5*cell_size, 5*cell_size]);

        % Clear previous kernel texts
        delete(findall(gcf, 'Type', 'text'));

        % Overlay kernel weights on left grid with spacing
        for ki = 1:3
            for kj = 1:3
                x_text = left_grid_x + (j - 2)*cell_size + (kj - 1.5)*2*cell_size + cell_size/2;
                y_text = (i - 2)*cell_size + (ki - 1.5)*2*cell_size + cell_size/2;
                text(x_text, y_text, num2str(kernel_3x3(ki, kj)), ...
                     'FontSize', 12, 'FontWeight', 'bold', ...
                     'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                     'Color', 'w');
            end
        end
    end
end

pause(2);

%%