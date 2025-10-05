clear; clc; close all;

%% Parameters

array_size = 9;        % Length of 1D array
cell_size = 50;        % Size of each cell
kernel_size = 3;       % 3x1 convolution kernel
pause_time = 0.3;      % Pause for animation

%% Input array (example)

input_array = [0 1 2 3 4 3 2 1 0]';

% Example kernels
kernel1 = [1 0 -1]';
kernel2 = [1 2 1]';

%% Figure setup

figure;
set(gcf, 'Color', 'k', 'Position', [100 100 300 1000]);
axis equal off;
ylim([-50, 2*array_size*cell_size + 50]);
xlim([-50, cell_size + 250]);
hold on;

% Draw left grid (input array, vertical)
for i = 1:array_size
    rectangle('Position', [0, (i-1)*cell_size, cell_size, cell_size], ...
              'EdgeColor', 'w', 'LineWidth', 1, ...
              'FaceColor', [0.3 0.3 0.3]);
    text(cell_size/2, (i-0.5)*cell_size, num2str(input_array(i)), ...
        'Color','w','FontSize',14,'HorizontalAlignment','center', 'VerticalAlignment','middle');
end

% Draw right grid (output array, initially black)
for i = 1:array_size
    rectangle('Position', [cell_size+50, (i-1)*cell_size, cell_size, cell_size], ...
              'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', [0 0 0]);
end

%% Convolution layer 1
output1 = zeros(array_size,1);
pause(3);
for i = array_size:-1:1
    % Determine kernel region (with zero padding)
    region_idx = (i-1)+(1:kernel_size);
    region_idx(region_idx < 1 | region_idx > array_size) = []; % clip
    region = input_array(region_idx);
    
    % Pad region if needed
    pad_len = kernel_size - length(region);
    if i == 1
        region = [zeros(pad_len,1); region];
    else
        region = [region; zeros(pad_len,1)];
    end
    
    % Convolve
    output1(i) = sum(region .* kernel1);
    
    % Highlight left cells
    h_left = rectangle('Position', [0, (i-2)*cell_size, cell_size, kernel_size*cell_size], ...
                'EdgeColor','y','LineWidth',3);

    % Highlight right cells
    h_right_1 = rectangle('Position', [100, (i-1)*cell_size, cell_size, cell_size], ...
                'EdgeColor','y','LineWidth',3);

    % Draw connecting lines from left 3x1 region to right 1x1 cell
    % Top line
    h_line_top = line([cell_size, cell_size+50], [(i-2+kernel_size)*cell_size, (i)*cell_size], ...
        'Color', 'y', 'LineWidth', 2);
    % Bottom line
    h_line_bot = line([cell_size, cell_size+50], [(i-2)*cell_size, (i-1)*cell_size], ...
        'Color', 'y', 'LineWidth', 2);
    
    % Update right grid
    h_right = rectangle('Position', [cell_size+50, (i-1)*cell_size, cell_size, cell_size], ...
                'EdgeColor','w','LineWidth',1, 'FaceColor', [1 1 1]*0.5);
    text(1.5*cell_size+50, (i-0.5)*cell_size, num2str(output1(i)), ...
        'Color','w','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    
    pause(pause_time);
    delete(h_left);
    delete(h_right_1);
    delete(h_line_top);
    delete(h_line_bot);
end

%% Convolution layers 2

%% Figure setup

figure;
set(gcf, 'Color', 'k', 'Position', [100 100 300 1000]);
axis equal off;
ylim([-200, 2*array_size*cell_size + 200]);
xlim([-200, cell_size + 450]);
hold on;

% Draw left grid (input array, vertical)
for i = 1:array_size
    rectangle('Position', [0, (i-1)*cell_size, cell_size, cell_size], ...
              'EdgeColor', 'w', 'LineWidth', 1, ...
              'FaceColor', [0.3 0.3 0.3]);
    text(cell_size/2, (i-0.5)*cell_size, num2str(input_array(i)), ...
        'Color','w','FontSize',14,'HorizontalAlignment','center', 'VerticalAlignment','middle');
end

% Draw right grid (output array, initially black)
for i = 1:array_size
    rectangle('Position', [cell_size+50, (i-1)*cell_size, cell_size, cell_size], ...
              'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', [0 0 0]);
    text(cell_size/2+100, (i-0.5)*cell_size, num2str(output1(i)), ...
        'Color','w','FontSize',14,'HorizontalAlignment','center', 'VerticalAlignment','middle');
end

% Draw right grid (output array, initially black)
for i = 1:array_size
    rectangle('Position', [cell_size+150, (i-1)*cell_size, cell_size, cell_size], ...
              'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', [0 0 0]);
end

%% Convolution layers 2

output2 = zeros(array_size,1);
pause(3);
for i = array_size:-1:1
    % Determine kernel region (with zero padding)
    region_idx = (i-1)+(1:kernel_size);
    region_idx(region_idx < 1 | region_idx > array_size) = []; % clip
    region = input_array(region_idx);
    
    % Pad region if needed
    pad_len = kernel_size - length(region);
    if i == 1
        region = [zeros(pad_len,1); region];
    else
        region = [region; zeros(pad_len,1)];
    end
    
    % Convolve
    output2(i) = sum(region .* kernel2);
    
    % Highlight left cells
    h_left = rectangle('Position', [0, (i-3)*cell_size, cell_size, (kernel_size+2)*cell_size], ...
                'EdgeColor','y','LineWidth',3);

    % Highlight right cells
    h_right_1 = rectangle('Position', [100, (i-2)*cell_size, cell_size, (kernel_size)*cell_size], ...
                'EdgeColor','y','LineWidth',3);

    % Highlight right cells
    h_right_2 = rectangle('Position', [200, (i-1)*cell_size, cell_size, cell_size], ...
                'EdgeColor','y','LineWidth',3);

    % Draw connecting lines from left 3x1 region to right 1x1 cell
    % Top line
    h_line_top_1 = line([cell_size, cell_size+50], [(i+2)*cell_size, (i+1)*cell_size], ...
        'Color', 'y', 'LineWidth', 2);
    % Bottom line
    h_line_bot_1 = line([cell_size, cell_size+50], [(i-3)*cell_size, (i-2)*cell_size], ...
        'Color', 'y', 'LineWidth', 2);
    
    % Draw connecting lines from left 3x1 region to right 1x1 cell
    % Top line
    h_line_top_2 = line([cell_size+100, cell_size+150], [(i+1)*cell_size, (i)*cell_size], ...
        'Color', 'y', 'LineWidth', 2);
    % Bottom line
    h_line_bot_2 = line([cell_size+100, cell_size+150], [(i-2)*cell_size, (i-1)*cell_size], ...
        'Color', 'y', 'LineWidth', 2);
    
    % Update right grid
    h_right = rectangle('Position', [cell_size+150, (i-1)*cell_size, cell_size, cell_size], ...
                'EdgeColor','w','LineWidth',1, 'FaceColor', [1 1 1]*0.5);
    text(1.5*cell_size+150, (i-0.5)*cell_size, num2str(output2(i)), ...
        'Color','w','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    
    pause(pause_time);
    delete(h_left);
    delete(h_right_1);
    delete(h_right_2);
    delete(h_line_top_1);
    delete(h_line_bot_1);
    delete(h_line_top_2);
    delete(h_line_bot_2);
end

%%
