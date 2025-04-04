clear;
tid = 2631;
px = [1, 2, 2, 4];
py = [1, 2, 4, 4];

figure;  % Create a single figure for all plots
hold on; % Ensure multiple plots are drawn on the same figure

legend_entries = {}; % Store legend entries

for i = 1:length(tid)  % Loop over time steps
    for j = 1:length(px)  % Loop over different px, py combinations
        ranks = 0:((px(j) * py(j)) - 1);
        all_data = [];
        proc_dims = zeros(length(ranks), 4);

        % Loop over ranks to gather data
        for r = 1:length(ranks)
            rank = ranks(r);

            % Read data for the current rank
            filename = sprintf('T_x_y_%06d_%04d_%d*%d.dat', tid(i), rank, px(j), py(j));
            data = dlmread(filename);
            
            % Get the unique x and y values
            x_local = unique(data(:, 1));
            y_local = unique(data(:, 2));
            
            % Number of points in the x and y directions
            nx = length(x_local);
            ny = length(y_local);
            
            % Store rank-specific info in proc_dims
            proc_dims(r, :) = [rank, nx, ny, size(all_data, 1) + 1];
            
            % Append the data to all_data
            all_data = [all_data; data];
        end
        
        % Prepare global grid based on all data
        x_global = unique(all_data(:, 1));
        y_global = unique(all_data(:, 2));
        nx_global = length(x_global);
        ny_global = length(y_global);
        
        % Initialize the global temperature array
        T_global = zeros(nx_global, ny_global);

        % Loop over ranks to populate the global temperature field
        for r = 1:length(ranks)
            rank = proc_dims(r, 1);
            nx = proc_dims(r, 2);
            ny = proc_dims(r, 3);
            start_idx = proc_dims(r, 4);
            
            data = all_data(start_idx:start_idx + nx * ny - 1, :);
            
            % Determine the rank position in the global grid
            x_vals = unique(data(:, 1));
            y_vals = unique(data(:, 2));
            
            [~, x_start] = min(abs(x_global - x_vals(1)));
            [~, y_start] = min(abs(y_global - y_vals(1)));

            % Reshape local temperature data into a 2D grid
            T_local = reshape(data(:, 3), [ny, nx])';
            
            % Insert local data into the global temperature array
            T_global(x_start:x_start + nx - 1, y_start:y_start + ny - 1) = T_local;
        end
        
        % Plot temperature profile at y = 0.5
        [~, mid_idx] = min(abs(y_global - 0.5));
        plot(x_global, T_global(:, mid_idx), '-', 'LineWidth', 2);

        % Store legend label
        legend_entries{end + 1} = sprintf('tid=%d, %dx%d', tid(i), px(j), py(j));
    end
end

xlabel('x');
ylabel('T');
title(sprintf('Comparison of Profile at y=0.5, timestep = %06d ', tid(i)));
legend(legend_entries);

saveas(gcf, 'Comparison_Profile_tid_2631.png');

% clear;
% tid = 0;
% px = [1, 2, 2, 4];
% py = [1, 2, 4, 4];
% 
% for j = 1:length(px)
%     ranks = 0:((px(j) * py(j)) - 1);
% 
%     for i = 1:length(tid)
%         all_data = [];
%         proc_dims = zeros(length(ranks), 4);
% 
%         % Loop over ranks to gather data
%         for r = 1:length(ranks)
%             rank = ranks(r);
%             nx = proc_dims(r, 2);  % These should be filled later
%             ny = proc_dims(r, 3);  % These should be filled later
%             start_idx = proc_dims(r, 4);  % Start index for each rank
% 
%             % Read data for the current rank
%             filename = sprintf('T_x_y_%06d_%04d_%d*%d.dat', tid(i), rank, px(j), py(j));
%             data = dlmread(filename);
%             
%             % Get the unique x and y values
%             x_local = unique(data(:, 1));
%             y_local = unique(data(:, 2));
%             
%             % Number of points in the x and y directions
%             nx = length(x_local);
%             ny = length(y_local);
%             
%             % Store rank-specific info in proc_dims
%             proc_dims(r, :) = [rank, nx, ny, size(all_data, 1) + 1];
%             
%             % Append the data to all_data
%             all_data = [all_data; data];
%         end
%         
%         % Prepare global grid based on all data
%         x_global = unique(all_data(:, 1));
%         y_global = unique(all_data(:, 2));
%         nx_global = length(x_global);
%         ny_global = length(y_global);
%         
%         % Initialize the global temperature array
%         T_global = zeros(nx_global, ny_global);
% 
%         % Loop over ranks to populate the global temperature field
%         for r = 1:length(ranks)
%             rank = proc_dims(r, 1);
%             nx = proc_dims(r, 2);
%             ny = proc_dims(r, 3);
%             start_idx = proc_dims(r, 4);
%             
%             data = all_data(start_idx:start_idx + nx * ny - 1, :);
%             
%             % Determine the rank position in the global grid
%             rank_x = mod(rank, px(j));  % Local x coordinate in global grid
%             rank_y = floor(rank / px(j));  % Local y coordinate in global grid
%             
%             % Find starting positions for the local grid in the global grid
%             x_vals = unique(data(:, 1));
%             y_vals = unique(data(:, 2));
%             
%             [~, x_start] = min(abs(x_global - x_vals(1)));
%             [~, y_start] = min(abs(y_global - y_vals(1)));
% 
%             
%             % Reshape local temperature data into a 2D grid
%             T_local = reshape(data(:, 3), [ny, nx])';
%             
%             % Insert local data into the global temperature array
%             T_global(x_start:x_start + nx - 1, y_start:y_start + ny - 1) = T_local;
%         end
% 
% 
%         [~, mid_idx] = min(abs(y_global - 0.5));
%         figure;
%         plot(x_global, T_global(:, mid_idx), '-', 'LineWidth', 2);
%         hold on;
%         xlabel('x');
%         ylabel('T');
%         title(sprintf('Comparison of Profile at y=0.5, timestep = %06d ', tid(i)));
%         legend(sprintf('%d*%d', px(j), py(j)))
%     end
%             % Plot temperature profile at y = 0.5
%                 % Uncomment to save the plot:
%         % saveas(gcf, sprintf('profile_T_%06d_%d_%d.png', tid(i), px(j), py(j)));
% end
