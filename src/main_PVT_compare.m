 %% main.m - Script to Read, Compare, Plot, and Save Two PVT Log Datasets

% This script reads data from two binary PVT log files using the
% 'read_pvt_bin' function. It then generates a series of comparison plots
% to visualize the differences/similarities in position, velocity, time,
% dilution of precision, and other related metrics between the two datasets.
% Finally, it saves all processed data into a .mat file for later use and
% saves all generated comparison plots as .fig and .png files.

% Ensure that 'read_pvt_bin.m' is in the reachable path
% or is on the MATLAB path.

clear; 
close all; clc;
addpath(genpath('C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\repositorios\gnss-flex\src')); 

options.SAVE_PLOT = 1;
cache_file = '../data/pvt_cache_flight_2.mat';
%% 0. Define Log Files and Read Data

log_filename1 = '..\data\CEDEA\vuelo_2_eme_rx_basic\run_2025-02-05_00-25-57\PVT.dat'; %EME Rx basic
log_filename2 = '..\data\CEDEA\vuelo_2_eme_rx_adv\run_2025-07-05_00-18-38\PVT.dat'; % EME Rx advanced
log_filename_septentrio = '..\data\CEDEA\17_jul_25\vuelo_2_mosaicX5\1ant1015.sbf_SBF_PVTGeodetic2.txt'; 

%% --- Define names/tags for each dataset for clarity in plots and legends ---
dataset_name_1 = 'EME Rx basic'; % e.g., 'Static Test', 'Receiver 1'
dataset_name_2 = 'EME Rx advanced'; % e.g., 'Dynamic Test', 'Receiver 2'
dataset_name_3 = 'Mosaic X5'; % e.g., 'Dynamic Test', 'Receiver 2'

output_mat_filename = '..\results\pvt_comparison_processed.mat'; % Name for the output .mat file
output_plots_folder = '..\results\plots_PVT'; % Folder to save comparison plots

if exist(cache_file, 'file')
    fprintf('Loading cached PVT data from %s...\n', cache_file);
    load(cache_file, 'data1', 'data2', 'data_sep');
else
    fprintf('Reading first PVT log file: %s\n', log_filename1);
    try
        data1 = read_pvt_bin(log_filename1);
        fprintf('Successfully read %d records from %s (%s).\n', ...
            length(data1.TOW), log_filename1, dataset_name_1);
    catch ME
        error('Error reading first PVT log file: %s\nEnsure the file exists and read_pvt_log.m is correct and on path.\nError: %s', ...
            log_filename1, ME.message);
    end

    fprintf('\nReading second PVT log file: %s\n', log_filename2);
    try
        data2 = read_pvt_bin(log_filename2);
        fprintf('Successfully read %d records from %s (%s).\n', ...
            length(data2.TOW), log_filename2, dataset_name_2);
    catch ME
        error('Error reading second PVT log file: %s\nEnsure the file exists and read_pvt_log.m is correct and on path.\nError: %s', ...
            log_filename2, ME.message);
    end

    fprintf('\nReading Septentrio PVT log file: %s\n', log_filename_septentrio);
    try
        data_sep = read_pvt_septentrio(log_filename_septentrio);
        fprintf('Successfully read %d records from %s (%s).\n', ...
            length(data_sep.TOW), log_filename_septentrio, dataset_name_3);
    catch ME
        error('Error reading Septentrio PVT log file: %s\nEnsure the file exists and read_pvt_septentrio.m is correct and on path.\nError: %s', ...
            log_filename_septentrio, ME.message);
    end

    % Save for future runs
    save(cache_file, 'data1', 'data2', 'data_sep', '-v7.3');
    fprintf('PVT data cached to %s.\n', cache_file);
end

%% 0.1. Prepare Data for Plotting (Dataset 1)
% Use the absolute Timestamp directly for plotting
abs_time_1 = data1.Timestamp; % Now holds datetime array

% DOPs
pdop_1 = data1.PDOP;
hdop_1 = data1.HDOP;
vdop_1 = data1.VDOP;
gdop_1 = data1.GDOP;

% Position (ECEF)
pos_x_1 = data1.PosX;
pos_y_1 = data1.PosY;
pos_z_1 = data1.PosZ;

% Geodetic Position
latitude_1 = data1.Lat;
longitude_1 = data1.Lon;
height_1 = data1.Height;

% Velocity (ECEF)
vel_x_1 = data1.VelX;
vel_y_1 = data1.VelY;
vel_z_1 = data1.VelZ;

% Covariance Diagonal Terms
cov_xx_1 = data1.Cov_xx;
cov_yy_1 = data1.Cov_yy;
cov_zz_1 = data1.Cov_zz;

% Ambiguity Resolution
AR_ratio_factor_1 = data1.AR_ratio;
AR_ratio_threshold_1 = data1.AR_thresh;

% Miscellaneous
user_clk_offset_1 = data1.ClockBias;
valid_sats_1 = data1.NumSV;
solution_type_1 = data1.SolStat; % Using SolStat for consistency with provided data structure

%% 0.2. Prepare Data for Plotting (Dataset 2)
abs_time_2 = data2.Timestamp; % Now holds datetime array

% DOPs
pdop_2 = data2.PDOP;
hdop_2 = data2.HDOP;
vdop_2 = data2.VDOP;
gdop_2 = data2.GDOP;

% Position (ECEF)
pos_x_2 = data2.PosX;
pos_y_2 = data2.PosY;
pos_z_2 = data2.PosZ;

% Geodetic Position
latitude_2 = data2.Lat;
longitude_2 = data2.Lon;
height_2 = data2.Height;

% Velocity (ECEF)
vel_x_2 = data2.VelX;
vel_y_2 = data2.VelY;
vel_z_2 = data2.VelZ;

% Covariance Diagonal Terms
cov_xx_2 = data2.Cov_xx;
cov_yy_2 = data2.Cov_yy;
cov_zz_2 = data2.Cov_zz;

% Ambiguity Resolution
AR_ratio_factor_2 = data2.AR_ratio;
AR_ratio_threshold_2 = data2.AR_thresh;

% Miscellaneous
user_clk_offset_2 = data2.ClockBias;
valid_sats_2 = data2.NumSV;
solution_type_2 = data2.SolStat; % Using SolStat for consistency with provided data structure

%% 0.3. Prepare Data for Plotting (Dataset 3)
abs_time_3 = data_sep.AbsTime_UTC; % Now holds datetime array

% % DOPs
% pdop_2 = data_sep.PDOP;
% hdop_2 = data_sep.HDOP;
% vdop_2 = data_sep.VDOP;
% gdop_2 = data_sep.GDOP;

% % Position (ECEF)
% pos_x_2 = data_sep.PosX;
% pos_y_2 = data_sep.PosY;
% pos_z_2 = data_sep.PosZ;

% Geodetic Position
latitude_3 = rad2deg(data_sep.Latitude);
longitude_3 = rad2deg(data_sep.Longitude);
height_3 = data_sep.Height;

% Velocity (ECEF)
vel_n_3 = data_sep.Vn;
vel_e_3 = data_sep.Ve;
vel_u_3 = data_sep.Vu;

% Ambiguity Resolution
% AR_ratio_factor_2 = data_sep.AR_ratio;
% AR_ratio_threshold_2 = data_sep.AR_thresh;

% Miscellaneous
user_clk_offset_3 = data_sep.RxClkBias;
user_clk_drift_3 = data_sep.RxClkDrift;
valid_sats_3 = data_sep.NrSV;
solution_type_3 = data_sep.Type; % Using SolStat for consistency with provided data structure

%% 0.4 Time Synchronization and Difference Calculation
fprintf('\nPerforming time synchronization and calculating differences...\n');

% Determine the common time range for interpolation across ALL THREE datasets
start_time_common = max([abs_time_1(1), abs_time_2(1), abs_time_3(1)])
end_time_common = min([abs_time_1(end), abs_time_2(end), abs_time_3(end)])

% Create a new, common time vector for interpolation
% We'll use the time points from dataset 1 that fall within the common range
% This assumes dataset 1 has a representative sampling rate.
idx_common_time_1 = abs_time_1 >= start_time_common & abs_time_1 <= end_time_common;
abs_time_sync = abs_time_1(idx_common_time_1);

% If the common time range is empty or too small, warn the user
if isempty(abs_time_sync) || length(abs_time_sync) < 2
    warning('Common time range between datasets is too small or empty. Differences might be unreliable.');
    % Fallback to min_len approach if synchronization fails meaningfully
    min_len = min(length(abs_time_1), length(abs_time_2));
    abs_time_sync = abs_time_1(1:min_len);
    if isempty(abs_time_sync)
        error('No common time points found between datasets. Cannot proceed with differences.');
    end
end

% Interpolate Dataset 2's data onto the synchronized time vector (abs_time_sync)
% Use 'linear' interpolation and 'extrap' for points slightly outside the range
% This handles cases where one dataset might slightly precede/follow the other
pdop_2_sync = interp1(abs_time_2, pdop_2, abs_time_sync, 'linear', 'extrap');
hdop_2_sync = interp1(abs_time_2, hdop_2, abs_time_sync, 'linear', 'extrap');
vdop_2_sync = interp1(abs_time_2, vdop_2, abs_time_sync, 'linear', 'extrap');
gdop_2_sync = interp1(abs_time_2, gdop_2, abs_time_sync, 'linear', 'extrap');

pos_x_2_sync = interp1(abs_time_2, pos_x_2, abs_time_sync, 'linear', 'extrap');
pos_y_2_sync = interp1(abs_time_2, pos_y_2, abs_time_sync, 'linear', 'extrap');
pos_z_2_sync = interp1(abs_time_2, pos_z_2, abs_time_sync, 'linear', 'extrap');

latitude_2_sync = interp1(abs_time_2, latitude_2, abs_time_sync, 'linear', 'extrap');
longitude_2_sync = interp1(abs_time_2, longitude_2, abs_time_sync, 'linear', 'extrap');
height_2_sync = interp1(abs_time_2, height_2, abs_time_sync, 'linear', 'extrap');

vel_x_2_sync = interp1(abs_time_2, vel_x_2, abs_time_sync, 'linear', 'extrap');
vel_y_2_sync = interp1(abs_time_2, vel_y_2, abs_time_sync, 'linear', 'extrap');
vel_z_2_sync = interp1(abs_time_2, vel_z_2, abs_time_sync, 'linear', 'extrap');

cov_xx_2_sync = interp1(abs_time_2, cov_xx_2, abs_time_sync, 'linear', 'extrap');
cov_yy_2_sync = interp1(abs_time_2, cov_yy_2, abs_time_sync, 'linear', 'extrap');
cov_zz_2_sync = interp1(abs_time_2, cov_zz_2, abs_time_sync, 'linear', 'extrap');

AR_ratio_factor_2_sync = interp1(abs_time_2, AR_ratio_factor_2, abs_time_sync, 'linear', 'extrap');
AR_ratio_threshold_2_sync = interp1(abs_time_2, AR_ratio_threshold_2, abs_time_sync, 'linear', 'extrap');

user_clk_offset_2_sync = interp1(abs_time_2, user_clk_offset_2, abs_time_sync, 'linear', 'extrap');
valid_sats_2_sync = interp1(abs_time_2, valid_sats_2, abs_time_sync, 'nearest', 'extrap'); % 'nearest' for discrete values
solution_type_2_sync = interp1(abs_time_2, solution_type_2, abs_time_sync, 'nearest', 'extrap'); % 'nearest' for discrete values

% Interpolate Dataset 3's data onto the synchronized time vector (abs_time_sync)
% Handle missing fields by assigning NaNs or skipping interpolation if field doesn't exist
% This assumes data3_raw has the fields as read by read_pvt_log, if not,
% you'd need more specific checks or a custom reader for data_sep.
if isfield(data_sep, 'PDOP')
    pdop_3_sync = interp1(abs_time_3, pdop_3, abs_time_sync, 'linear', 'extrap');
    hdop_3_sync = interp1(abs_time_3, hdop_3, abs_time_sync, 'linear', 'extrap');
    vdop_3_sync = interp1(abs_time_3, vdop_3, abs_time_sync, 'linear', 'extrap');
    gdop_3_sync = interp1(abs_time_3, gdop_3, abs_time_sync, 'linear', 'extrap');
else
    pdop_3_sync = NaN(size(abs_time_sync)); hdop_3_sync = NaN(size(abs_time_sync));
    vdop_3_sync = NaN(size(abs_time_sync)); gdop_3_sync = NaN(size(abs_time_sync));
end

if isfield(data_sep, 'PosX')
    pos_x_3_sync = interp1(abs_time_3, pos_x_3, abs_time_sync, 'linear', 'extrap');
    pos_y_3_sync = interp1(abs_time_3, pos_y_3, abs_time_sync, 'linear', 'extrap');
    pos_z_3_sync = interp1(abs_time_3, pos_z_3, abs_time_sync, 'linear', 'extrap');
else
    pos_x_3_sync = NaN(size(abs_time_sync)); pos_y_3_sync = NaN(size(abs_time_sync));
    pos_z_3_sync = NaN(size(abs_time_sync));
end

latitude_3_sync = interp1(abs_time_3, latitude_3, abs_time_sync, 'linear', 'extrap');
longitude_3_sync = interp1(abs_time_3, longitude_3, abs_time_sync, 'linear', 'extrap');
height_3_sync = interp1(abs_time_3, height_3, abs_time_sync, 'linear', 'extrap');

if isfield(data_sep, 'Cov_xx')
    cov_xx_3_sync = interp1(abs_time_3, cov_xx_3, abs_time_sync, 'linear', 'extrap');
    cov_yy_3_sync = interp1(abs_time_3, cov_yy_3, abs_time_sync, 'linear', 'extrap');
    cov_zz_3_sync = interp1(abs_time_3, cov_zz_3, abs_time_sync, 'linear', 'extrap');
else
    cov_xx_3_sync = NaN(size(abs_time_sync)); cov_yy_3_sync = NaN(size(abs_time_sync));
    cov_zz_3_sync = NaN(size(abs_time_sync));
end

if isfield(data_sep, 'AR_ratio')
    AR_ratio_factor_3_sync = interp1(abs_time_3, AR_ratio_factor_3, abs_time_sync, 'linear', 'extrap');
    AR_ratio_threshold_3_sync = interp1(abs_time_3, AR_ratio_threshold_3, abs_time_sync, 'linear', 'extrap');
else
    AR_ratio_factor_3_sync = NaN(size(abs_time_sync)); AR_ratio_threshold_3_sync = NaN(size(abs_time_sync));
end

user_clk_offset_3_sync = interp1(abs_time_3, user_clk_offset_3, abs_time_sync, 'linear', 'extrap');
% user_clk_drift_3_sync = interp1(abs_time_3, user_clk_drift_3, abs_time_sync, 'linear', 'extrap'); % Only in data_sep
valid_sats_3_sync = interp1(abs_time_3, valid_sats_3, abs_time_sync, 'nearest', 'extrap');
% solution_type_3_sync = interp1(abs_time_3, solution_type_3, abs_time_sync, 'nearest', 'extrap');


% Also truncate Dataset 1 to the synchronized time vector for direct subtraction
pdop_1_sync = pdop_1(idx_common_time_1);
hdop_1_sync = hdop_1(idx_common_time_1);
vdop_1_sync = vdop_1(idx_common_time_1);
gdop_1_sync = gdop_1(idx_common_time_1);

pos_x_1_sync = pos_x_1(idx_common_time_1);
pos_y_1_sync = pos_y_1(idx_common_time_1);
pos_z_1_sync = pos_z_1(idx_common_time_1);

latitude_1_sync = latitude_1(idx_common_time_1);
longitude_1_sync = longitude_1(idx_common_time_1);
height_1_sync = height_1(idx_common_time_1);

vel_x_1_sync = vel_x_1(idx_common_time_1);
vel_y_1_sync = vel_y_1(idx_common_time_1);
vel_z_1_sync = vel_z_1(idx_common_time_1);

cov_xx_1_sync = cov_xx_1(idx_common_time_1);
cov_yy_1_sync = cov_yy_1(idx_common_time_1);
cov_zz_1_sync = cov_zz_1(idx_common_time_1);

AR_ratio_factor_1_sync = AR_ratio_factor_1(idx_common_time_1);
AR_ratio_threshold_1_sync = AR_ratio_threshold_1(idx_common_time_1);

user_clk_offset_1_sync = user_clk_offset_1(idx_common_time_1);
valid_sats_1_sync = valid_sats_1(idx_common_time_1);
solution_type_1_sync = solution_type_1(idx_common_time_1);


% Now calculate the differences using the synchronized data
% DOPs Differences (Only 1 vs 2, as 3 might not have these)
pdop_diff_12 = pdop_1_sync - pdop_2_sync;
hdop_diff_12 = hdop_1_sync - hdop_2_sync;
vdop_diff_12 = vdop_1_sync - vdop_2_sync;
gdop_diff_12 = gdop_1_sync - gdop_2_sync;

% Position (ECEF) Differences (Only 1 vs 2, as 3 might not have these)
pos_x_diff_12 = pos_x_1_sync - pos_x_2_sync;
pos_y_diff_12 = pos_y_1_sync - pos_y_2_sync;
pos_z_diff_12 = pos_z_1_sync - pos_z_2_sync;

% Geodetic Position Differences (1 vs 2, and 1 vs 3)
latitude_diff_12 = latitude_1_sync - latitude_2_sync;
longitude_diff_12 = longitude_1_sync - longitude_2_sync;
% height_diff_12 = height_1_sync - height_2_sync;

latitude_diff_13 = latitude_1_sync - latitude_3_sync;
longitude_diff_13 = longitude_1_sync - longitude_3_sync;
% height_diff_13 = height_1_sync - height_3_sync;

latitude_diff_23 = latitude_2_sync - latitude_3_sync;
longitude_diff_23 = longitude_2_sync - longitude_3_sync;
% height_diff_23 = height_2_sync - height_3_sync;

% Velocity (ECEF) Differences (Only 1 vs 2, as 3 might be ENU)
vel_x_diff_12 = vel_x_1_sync - vel_x_2_sync;
vel_y_diff_12 = vel_y_1_sync - vel_y_2_sync;
vel_z_diff_12 = vel_z_1_sync - vel_z_2_sync;

% Covariance Diagonal Terms Differences (Only 1 vs 2, as 3 might not have these)
cov_xx_diff_12 = cov_xx_1_sync - cov_xx_2_sync;
cov_yy_diff_12 = cov_yy_1_sync - cov_yy_2_sync;
cov_zz_diff_12 = cov_zz_1_sync - cov_zz_2_sync;

% Ambiguity Resolution Differences (Only 1 vs 2, as 3 might not have these)
AR_ratio_factor_diff_12 = AR_ratio_factor_1_sync - AR_ratio_factor_2_sync;
AR_ratio_threshold_diff_12 = AR_ratio_threshold_1_sync - AR_ratio_threshold_2_sync;

% Miscellaneous Differences (1 vs 2, and 1 vs 3)
user_clk_offset_diff_12 = user_clk_offset_1_sync - user_clk_offset_2_sync;
valid_sats_diff_12 = valid_sats_1_sync - valid_sats_2_sync;
solution_type_diff_12 = solution_type_1_sync - solution_type_2_sync;

user_clk_offset_diff_13 = user_clk_offset_1_sync - user_clk_offset_3_sync;
valid_sats_diff_13 = valid_sats_1_sync - valid_sats_3_sync;
% solution_type_diff_13 = solution_type_1_sync - solution_type_3_sync;

% Calculate 3D ECEF Position Error Magnitude (for 1 vs 2)
pos_ecef_error_mag_12 = sqrt(pos_x_diff_12.^2 + pos_y_diff_12.^2 + pos_z_diff_12.^2);

%% 1. DOPs (Dilution of Precision) Differences
figure('Name','DOPs_Differences');
plot(abs_time_sync, pdop_diff_12, 'k-', ...
     abs_time_sync, hdop_diff_12, 'b-', ...
     abs_time_sync, vdop_diff_12, 'r-', ...
     abs_time_sync, gdop_diff_12, 'g-');
legend('PDOP Diff','HDOP Diff','VDOP Diff','GDOP Diff', 'Location', 'best');
grid on;
xlabel('Time (UTC)');
ylabel('DOP Difference');
title(sprintf('Dilution of Precision Differences (%s - %s)', dataset_name_1, dataset_name_2));
grid minor;

%% 2. Position in ECEF (Earth-Centered, Earth-Fixed) Coordinates Differences
figure('Name','Position_ECEF_Differences');
plot(abs_time_sync, pos_x_diff_12, 'r', ...
     abs_time_sync, pos_y_diff_12, 'g', ...
     abs_time_sync, pos_z_diff_12, 'b');
legend('Delta X','Delta Y','Delta Z', 'Location', 'best');
grid on;
xlabel('Time (UTC)');
ylabel('Position Difference (m)');
title(sprintf('Position (ECEF) Differences (%s - %s)', dataset_name_1, dataset_name_2));
grid minor;

%% 3. Latitude, Longitude, Height (2D Geodetic Position on Map) Comparison
% This plot shows both trajectories overlaid, as a direct difference on a map
% is generally not intuitive for geographic coordinates.
figure('Name','2D_Geodetic_Position_Map_Comparison');
% Filter out any non-finite (NaN, Inf) values before plotting
valid_geo_idx_1 = isfinite(latitude_1) & isfinite(longitude_1) & isfinite(height_1);
valid_geo_idx_2 = isfinite(latitude_2) & isfinite(longitude_2) & isfinite(height_2);

geoscatter(latitude_1(valid_geo_idx_1), longitude_1(valid_geo_idx_1), 10, height_1(valid_geo_idx_1), 'filled');
hold on;
geoscatter(latitude_2(valid_geo_idx_2), longitude_2(valid_geo_idx_2), 10, height_2(valid_geo_idx_2), 'o'); % Use 'o' for second dataset
hold off;
colorbar;
title('Latitude & Longitude with Height (colored) Comparison');
geobasemap('satellite'); % You can try 'streets', 'topographic', 'grayland'
legend(sprintf('%s (Colored by Height)', dataset_name_1), sprintf('%s (Markers)', dataset_name_2), 'Location', 'best'); % Custom legend for geoscatter

%% 4. Velocity in ECEF Coordinates Differences
figure('Name','Velocity_Differences');
plot(abs_time_sync, vel_x_diff_12, 'r-', ...
     abs_time_sync, vel_y_diff_12, 'g-', ...
     abs_time_sync, vel_z_diff_12, 'b-');
legend('Delta Vx','Delta Vy','Delta Vz', 'Location', 'best');
grid on;
xlabel('Time (UTC)');
ylabel('Velocity Difference (m/s)');
title(sprintf('Velocity in ECEF Differences (%s - %s)', dataset_name_1, dataset_name_2));
grid minor;

%% 5. Covariance Diagonal Terms Differences
figure('Name','Covariance_Diagonals_Differences');
plot(abs_time_sync, cov_xx_diff_12, 'r-', ...
     abs_time_sync, cov_yy_diff_12, 'g-', ...
     abs_time_sync, cov_zz_diff_12, 'b-');
legend('Delta cov_{xx}','Delta cov_{yy}','Delta cov_{zz}', 'Location', 'best');
xlabel('Time (UTC)');
ylabel('Covariance Difference (m^2)');
title(sprintf('Position Covariance Diagonal Differences (%s - %s)', dataset_name_1, dataset_name_2));
grid on;
grid minor;

%% 6. AR Ratio and Threshold Differences
figure('Name','Ambiguity_Resolution_Differences');
plot(abs_time_sync, AR_ratio_factor_diff_12, 'b-', ...
     abs_time_sync, AR_ratio_threshold_diff_12, 'r--');
legend('AR Ratio Diff','Threshold Diff', 'Location', 'best');
xlabel('Time (UTC)');
ylabel('Ratio Difference');
title(sprintf('Ambiguity Resolution Ratio Differences (%s - %s)', dataset_name_1, dataset_name_2));
grid on;
grid minor;

%% 7. Miscellaneous Differences
figure('Name','Miscellaneous_Differences');
subplot(3,1,1);
plot(abs_time_sync, user_clk_offset_diff_12, 'b-');
ylabel('Clk Offset Diff (s)');
legend('Clock Offset Difference', 'Location', 'best');
grid minor;

subplot(3,1,2);
plot(abs_time_sync, valid_sats_diff_12, 'g-');
ylabel('# Sats Diff');
legend('Number of Satellites Difference', 'Location', 'best');
grid minor;

subplot(3,1,3);
plot(abs_time_sync, solution_type_diff_12, 'r-');
ylabel('Sol. Type Diff');
legend('Solution Type Difference', 'Location', 'best');
grid minor;

xlabel('Time (UTC)');
sgtitle(sprintf('Clock, Sats, Solution Differences (%s - %s)', dataset_name_1, dataset_name_2));
grid minor;

%% 8. PDOP Distribution on Geographic Map Comparison
% This plot shows both datasets overlaid, as a direct difference on a map
% is generally not intuitive for geographic coordinates.
% Filter out invalid entries for geoscatter plots
valid_idx_pdop_1 = isfinite(latitude_1) & isfinite(longitude_1) & isfinite(pdop_1);
lat_pdop_1 = latitude_1(valid_idx_pdop_1);
lon_pdop_1 = longitude_1(valid_idx_pdop_1);
pdop_vals_1 = pdop_1(valid_idx_pdop_1);

valid_idx_pdop_2 = isfinite(latitude_2) & isfinite(longitude_2) & isfinite(pdop_2);
lat_pdop_2 = latitude_2(valid_idx_pdop_2);
lon_pdop_2 = longitude_2(valid_idx_pdop_2);
pdop_vals_2 = pdop_2(valid_idx_pdop_2);

figure('Name', 'PDOP_on_Map_Comparison');
geoscatter(lat_pdop_1, lon_pdop_1, 20, pdop_vals_1, 'filled');
hold on;
geoscatter(lat_pdop_2, lon_pdop_2, 20, pdop_vals_2, 'o'); % Different marker for second dataset
hold off;
geobasemap('topographic');
colorbar;
title('PDOP Distribution on Geographic Map Comparison');
c = colorbar;
c.Label.String = sprintf('PDOP (%s)', dataset_name_1); % Colorbar reflects dataset 1
legend(sprintf('%s PDOP', dataset_name_1), sprintf('%s PDOP', dataset_name_2), 'Location', 'best');

%% 9. Number of Satellites on Geographic Map Comparison
% This plot shows both datasets overlaid, as a direct difference on a map
% is generally not intuitive for geographic coordinates.
% Filter valid data for geoscatter plots
valid_idx_sats_1 = isfinite(latitude_1) & isfinite(longitude_1) & isfinite(valid_sats_1);
lat_sats_1 = latitude_1(valid_idx_sats_1);
lon_sats_1 = longitude_1(valid_idx_sats_1);
nsats_1 = valid_sats_1(valid_idx_sats_1);

valid_idx_sats_2 = isfinite(latitude_2) & isfinite(longitude_2) & isfinite(valid_sats_2);
lat_sats_2 = latitude_2(valid_idx_sats_2);
lon_sats_2 = longitude_2(valid_idx_sats_2);
nsats_2 = valid_sats_2(valid_idx_sats_2);

figure('Name', 'Num_Satellites_on_Map_Comparison');
geoscatter(lat_sats_1, lon_sats_1, 20, nsats_1, 'filled');
hold on;
geoscatter(lat_sats_2, lon_sats_2, 20, nsats_2, 'o'); % Different marker for second dataset
hold off;
geobasemap('topographic');
title('Number of Valid Satellites on Geographic Map Comparison');
colormap(flipud(turbo));
c = colorbar;
c.Label.String = sprintf('Valid Satellites (%s)', dataset_name_1); % Colorbar reflects dataset 1
legend(sprintf('%s Sats', dataset_name_1), sprintf('%s Sats', dataset_name_2), 'Location', 'best');

%% 2D Trajectory Differences (Lat/Lon to Meters) - Subplots for all pairs

% Define ellipsoid and common mean latitude (from dataset 1)
ellipsoid = wgs84Ellipsoid;
a = ellipsoid.SemimajorAxis;
e2 = ellipsoid.Eccentricity^2;

% Dataset 1 vs 2
lat1 = latitude_1_sync;
lon1 = longitude_1_sync;
lat2 = latitude_2_sync;
lon2 = longitude_2_sync;

mean_lat_rad_12 = deg2rad(mean(lat1, 'omitnan'));
Rn_12 = a / sqrt(1 - e2 * sin(mean_lat_rad_12)^2);
Rm_12 = a * (1 - e2) / (1 - e2 * sin(mean_lat_rad_12)^2)^(3/2);
diff_lat_deg_12 = lat1 - lat2;
diff_lon_deg_12 = lon1 - lon2;
delta_north_12 = diff_lat_deg_12 .* (pi/180) .* Rm_12;
delta_east_12  = diff_lon_deg_12 .* (pi/180) .* Rn_12 .* cos(mean_lat_rad_12);

% Dataset 1 vs 3
lat3 = latitude_3_sync;
lon3 = longitude_3_sync;

mean_lat_rad_13 = deg2rad(mean(lat1, 'omitnan'));
Rn_13 = a / sqrt(1 - e2 * sin(mean_lat_rad_13)^2);
Rm_13 = a * (1 - e2) / (1 - e2 * sin(mean_lat_rad_13)^2)^(3/2);
diff_lat_deg_13 = lat1 - lat3;
diff_lon_deg_13 = lon1 - lon3;
delta_north_13 = diff_lat_deg_13 .* (pi/180) .* Rm_13;
delta_east_13  = diff_lon_deg_13 .* (pi/180) .* Rn_13 .* cos(mean_lat_rad_13);

% Dataset 2 vs 3
lat2 = latitude_2_sync;
lon2 = longitude_2_sync;
mean_lat_rad_23 = deg2rad(mean(lat2, 'omitnan'));
Rn_23 = a / sqrt(1 - e2 * sin(mean_lat_rad_23)^2);
Rm_23 = a * (1 - e2) / (1 - e2 * sin(mean_lat_rad_23)^2)^(3/2);
diff_lat_deg_23 = lat2 - lat3;
diff_lon_deg_23 = lon2 - lon3;
delta_north_23 = diff_lat_deg_23 .* (pi/180) .* Rm_23;
delta_east_23  = diff_lon_deg_23 .* (pi/180) .* Rn_23 .* cos(mean_lat_rad_23);

% Plot all three comparisons in subplots
figure('Name','2D_Trajectory_Differences_All');

subplot(1,3,1);
plot(delta_east_12, delta_north_12, '.-b');
hold on; plot(0,0,'ko','LineWidth',1.5); hold off;
axis equal; grid on; grid minor;
xlabel('Delta East (m)'); ylabel('Delta North (m)');
title(sprintf('2D Trajectory Difference (%s - %s)', dataset_name_1, dataset_name_2));
legend('Difference', 'Origin');

subplot(1,3,2);
plot(delta_east_13, delta_north_13, '.-r');
hold on; plot(0,0,'ko','LineWidth',1.5); hold off;
axis equal; grid on; grid minor;
xlabel('Delta East (m)'); ylabel('Delta North (m)');
title(sprintf('2D Trajectory Difference (%s - %s)', dataset_name_1, dataset_name_3));
legend('Difference', 'Origin');

subplot(1,3,3);
plot(delta_east_23, delta_north_23, '.-g');
hold on; plot(0,0,'ko','LineWidth',1.5); hold off;
axis equal; grid on; grid minor;
xlabel('Delta East (m)'); ylabel('Delta North (m)');
title(sprintf('2D Trajectory Difference (%s - %s)', dataset_name_2, dataset_name_3));
legend('Difference', 'Origin');

%% Altura - Diferencias (Height differences) para los tres pares, con eje x en tiempo absoluto

% Variables de tiempo absolutas sincronizadas
time_1 = abs_time_sync; % datetime vector para dataset 1
time_2 = abs_time_sync; % dataset 2
time_3 = abs_time_sync; % dataset 3

% Diferencias de altura para cada par
height_1 = height_1_sync;
height_2 = height_2_sync;
height_3 = height_3_sync;

height_diff_12 = height_1 - height_2;
height_diff_13 = height_1 - height_3;
height_diff_23 = height_2 - height_3;

% Para las comparaciones 1-2 y 1-3 usar tiempo del dataset 1 (asumido común)
% Para la comparación 2-3 usar tiempo del dataset 2

figure('Name','Height_Differences_All_Time');

subplot(3,1,1);
plot(time_1, height_diff_12, '.-b');
grid on; grid minor;
xlabel('Time (UTC)');
ylabel('Height Difference (m)');
title(sprintf('Height Difference (%s - %s)', dataset_name_1, dataset_name_2));
hold on;
yline(0,'k--'); % Línea base en cero
hold off;

subplot(3,1,2);
plot(time_1, height_diff_13, '.-r');
grid on; grid minor;
xlabel('Time (UTC)');
ylabel('Height Difference (m)');
title(sprintf('Height Difference (%s - %s)', dataset_name_1, dataset_name_3));
hold on;
yline(0,'k--');
hold off;

subplot(3,1,3);
plot(time_2, height_diff_23, '.-g');
grid on; grid minor;
xlabel('Time (UTC)');
ylabel('Height Difference (m)');
title(sprintf('Height Difference (%s - %s)', dataset_name_2, dataset_name_3));
hold on;
yline(0,'k--');
hold off;

%% Histogramas de diferencias de altura para los tres pares

figure('Name','Histograms_Height_Differences');

subplot(3,1,1);
histogram(height_diff_12, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Height Difference (m)');
ylabel('Probability');
title(sprintf('Height Difference Histogram (%s - %s)', dataset_name_1, dataset_name_2));
grid on;
grid minor;

subplot(3,1,2);
histogram(height_diff_13, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Height Difference (m)');
ylabel('Probability');
title(sprintf('Height Difference Histogram (%s - %s)', dataset_name_1, dataset_name_3));
grid on;
grid minor;

subplot(3,1,3);
histogram(height_diff_23, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Height Difference (m)');
ylabel('Probability');
title(sprintf('Height Difference Histogram (%s - %s)', dataset_name_2, dataset_name_3));
grid on;
grid minor;

sgtitle('Height Difference Distributions'); % Título general para la figura

%% 10b. Histograms of ECEF Position Error Components 1v2
figure('Name','Histograms_ECEF_Position_Error_Components');

% Subplot for X-difference
subplot(3,1,1);
histogram(pos_x_diff_12, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta X (m)');
ylabel('Probability');
title(sprintf('X Position Error Histogram (%s - %s)', dataset_name_1, dataset_name_2));
grid on;xlim([-20 20])
grid minor;

% Subplot for Y-difference
subplot(3,1,2);
histogram(pos_y_diff_12, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta Y (m)');
ylabel('Probability');
title(sprintf('Y Position Error Histogram (%s - %s)', dataset_name_1, dataset_name_2));
grid on;xlim([-20 20])
grid minor;

% Subplot for Z-difference
subplot(3,1,3);
histogram(pos_z_diff_12, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta Z (m)');
ylabel('Probability');
title(sprintf('Z Position Error Histogram (%s - %s)', dataset_name_1, dataset_name_2));
grid on;xlim([-20 20])
grid minor;

sgtitle('ECEF Position Error Component Distributions'); % Super title for the figure

%%

%% Histogramas de diferencias 2D de posición (Delta East, Delta North) para los tres pares

figure('Name','Histograms_2D_Position_Error_Components_All');

% --- Par 1 vs 2 ---
subplot(3,2,1);
histogram(delta_east_12, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta East (m)');
ylabel('Probability');
title(sprintf('East Position Error (%s - %s)', dataset_name_1, dataset_name_2));
grid on; xlim([-20 20]);
grid minor;

subplot(3,2,2);
histogram(delta_north_12, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta North (m)');
ylabel('Probability');
title(sprintf('North Position Error (%s - %s)', dataset_name_1, dataset_name_2));
grid on; xlim([-20 20]);
grid minor;

% --- Par 1 vs 3 ---
subplot(3,2,3);
histogram(delta_east_13, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta East (m)');
ylabel('Probability');
title(sprintf('East Position Error (%s - %s)', dataset_name_1, dataset_name_3));
grid on; xlim([-20 20]);
grid minor;

subplot(3,2,4);
histogram(delta_north_13, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta North (m)');
ylabel('Probability');
title(sprintf('North Position Error (%s - %s)', dataset_name_1, dataset_name_3));
grid on; xlim([-20 20]);
grid minor;

% --- Par 2 vs 3 ---
subplot(3,2,5);
histogram(delta_east_23, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta East (m)');
ylabel('Probability');
title(sprintf('East Position Error (%s - %s)', dataset_name_2, dataset_name_3));
grid on; xlim([-20 20]);
grid minor;

subplot(3,2,6);
histogram(delta_north_23, 'BinMethod', 'auto', 'Normalization', 'probability');
xlabel('Delta North (m)');
ylabel('Probability');
title(sprintf('North Position Error (%s - %s)', dataset_name_2, dataset_name_3));
grid on; xlim([-20 20]);
grid minor;

sgtitle('2D Position Error Component Distributions (North, East)');


%% 11. Save Processed Data to .mat file
% TBC save to output_mat_filename

%% 12. Save All Generated Plots
if options.SAVE_PLOT
    figs = findall(0, 'Type', 'figure');
    for k = 1:length(figs)
        figs(k).WindowState = 'maximized';
    end
    
    % Create a folder to store the plots if it doesn't exist
    if ~exist(output_plots_folder, 'dir')
        mkdir(output_plots_folder);
        fprintf('Created folder for plots: %s\n', output_plots_folder);
    end
    
    % Get a list of all open figures
    all_figures = findall(0, 'Type', 'figure');
    
    fprintf('Saving %d comparison plots to folder: %s...\n', length(all_figures), output_plots_folder);
    
    for fig_handle = all_figures' % Iterate through each figure handle
        fig_name = get(fig_handle, 'Name'); % Get the name of the figure
        if isempty(fig_name)
            fig_name = ['Figure_' num2str(fig_handle.Number)]; % Use figure number if no name
        end
    
        % Sanitize figure name for use in filenames (replace invalid characters)
        fig_name_sanitized = strrep(fig_name, ' ', '_'); % Replace spaces with underscores
        fig_name_sanitized = regexprep(fig_name_sanitized, '[^a-zA-Z0-9_.-]', ''); % Remove other invalid chars
    
        % Define full paths for saving
        fig_filepath = fullfile([output_plots_folder '\fig'], [fig_name_sanitized '.fig']);
        png_filepath = fullfile(output_plots_folder, [fig_name_sanitized '.png']);
    
        try
            % Save as MATLAB figure file (.fig)
            savefig(fig_handle, fig_filepath);
            % Save as PNG image file (.png)
            exportgraphics(fig_handle, png_filepath, 'Resolution', 300); % High resolution PNG
            fprintf('  Saved "%s" as .fig and .png\n', fig_name);
        catch ME_plot
            warning('Failed to save plot "%s": %s', fig_name, ME_plot.message);
        end
    end
end
%%
if options.SAVE_PLOT
fprintf('----------------------------------------------------------.\n');
fprintf('All comparison plots generated and data saved successfully.\n');
else
fprintf('----------------------------------------------------------.\n');
fprintf('All comparison plots generated.\n');
end