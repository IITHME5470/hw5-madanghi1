clc; clear; close all;

nx = 400; ny = 400;
files = {'T_x_y_015920.dat', 'T_x_y_015920_2.dat', 'T_x_y_015920_4.dat', 'T_x_y_015920_8.dat'};
T = cell(1, 4);
for i = 1:4
    data = dlmread(files{i});
    T{i} = reshape(data(:, 3), [nx, ny]); 
end

compute_error = @(A, B) deal(sqrt(mean((A - B).^2, 'all')));

[L2_p2] = compute_error(T{1}, T{2}); % Serial vs p=2
[L2_p4] = compute_error(T{1}, T{3}); % Serial vs p=4
[L2_p8] = compute_error(T{1}, T{4}); % Serial vs p=8

fprintf('Error (serial vs p=2): L2 = %.15e\n', L2_p2);
fprintf('Error (serial vs p=4): L2 = %.15e\n', L2_p4);
fprintf('Error (serial vs p=8): L2 = %.15e\n', L2_p8);
