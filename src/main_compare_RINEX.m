%% -----------------------------------------------------------
%  Script Name:   main_compare_RINEX.m
%  Description:   Processes GNSS RINEX and PVT from several sources
%  Author:        gomezlma@inta.es
%  Date:          [2025-07-28]
%  Inputs:        RINEX files.
%  Outputs:       Processed and plots of GNSS data.
%  Dependencies:  Requires MATLAB R2020b or later.
%  -----------------------------------------------------------
close all
clearvars
clc

%%
% Add that folder plus all subfolders to the path.
addpath(genpath('C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\repositorios\gnss-flex\src')); 
SAVE_PLOT = 1
CLOSE_at_END = 0
SAVE_VIDEO_SKYPLOT = 0

%%
path_folder='C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\2 INTA\6 GNSS-flex\data_cedea\';
day_folder='17_jul_25\';
rx_advanced_folder='vuelo_2_eme_rx_adv\run_2025-07-05_00-18-38\';
rx_basic_folder='vuelo_2_eme_rx_basic\run_2025-02-05_00-25-57\';
mosaic_x5_folder='septentrio_1_antenna_17_jul_25\';

%% -------------------------- OBSERVABLES ----------------------------------
% Import RINEX

% SCRAB II Basic Rx
experiment='SCRAB II Basic Rx';
observation_file = [path_folder day_folder rx_basic_folder 'GSDR036a25.25O'];
result_directory = [path_folder day_folder 'figures_rx_basic'];
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
satellitePRNs = [];
RINEX_process_postproc(experiment, observation_file, result_directory, satellitePRNs, SAVE_PLOT)

% SCRAB II Advanced Rx
experiment='SCRAB II Advanced Rx';
observation_file = [path_folder day_folder rx_advanced_folder 'GSDR186a18.25O'];
result_directory = [path_folder day_folder 'figures_rx_advanced'];
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
satellitePRNs = [];
RINEX_process_postproc(experiment, observation_file, result_directory, satellitePRNs, SAVE_PLOT)

% SCRAB II MOSAIC-X5
experiment='SCRAB II MOSAIC-X5';
observation_file = [path_folder day_folder mosaic_x5_folder '1ant1015.obs'];
result_directory = [path_folder day_folder 'figures_mosaicX5'];
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
satellitePRNs = [];
RINEX_process_postproc(experiment, observation_file, result_directory, satellitePRNs, SAVE_PLOT)
%%
close all

%% COMPARE RINEX Advanced Rx vs Basic Rx
%
experiment='SCRAB II flight - Advanced Rx vs Basic Rx';
input_files_eme_rx_adv = [path_folder day_folder rx_advanced_folder 'GSDR186a18.25O']; label1='rx advanced EME';
input_files_eme_rx_basic = [path_folder day_folder rx_basic_folder 'GSDR036a25.25O']; label2='rx basic EME';

input_files_mosaicX5 = [path_folder day_folder mosaic_x5_folder '1ant1015.obs']; label3='rx MOSAIC';
result_directory = [path_folder day_folder 'figures_comparision_RINEX'];
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
satellitePRNs = [];

compare_rinex_observables( experiment, ...
    input_files_eme_rx_adv, ...
    input_files_eme_rx_basic, ...
    result_directory, ...
    satellitePRNs, ...  % ejemplo de PRNs a comparar
    true,'GPS');
%% COMPARE RINEX Advanced Rx vs Mosaic X5
%
experiment='SCRAB II flight - Advanced Rx vs Mosaic X5';
result_directory = [path_folder day_folder 'figures_comparision_RINEX'];
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
satellitePRNs = [];

compare_rinex_observables( experiment, ...
    input_files_eme_rx_adv, ...
    input_files_mosaicX5, ...
    result_directory, ...
    satellitePRNs, ...  % ejemplo de PRNs a comparar
    true,'GPS');
%% COMPARE RINEX Basic Rx vs Mosaic X5
%
experiment='SCRAB II flight - Basic Rx vs Mosaic X5';
result_directory = [path_folder day_folder 'figures_comparision_RINEX'];
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
satellitePRNs = [];

compare_rinex_observables( experiment, ...
    input_files_eme_rx_basic, ...
    input_files_mosaicX5, ...
    result_directory, ...
    satellitePRNs, ...  % ejemplo de PRNs a comparar
    true,'GPS');


%% GNSS-SDR PARSER
% experiment = 'gnss SDR observables ISS';
% gnss_sdr_matfile =  '../rinex_and_raw/observables.mat'; 
% result_directory = '../figures/';
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
% startTime = datetime(2024, 5, 25, 16, 0, 0);
% bin_size=50; 
% 
% GNSS_SDR_OBSERVABLES_process_binned(experiment, gnss_sdr_matfile, result_directory, satellitePRNs, startTime, SAVE_PLOT,bin_size)
%% GNSS-SDR PARSER no clk corr
% experiment = 'gnss SDR observables ISS no clk corr';
% gnss_sdr_matfile =  '../rinex_and_raw/observables_no_clk_corr.mat'; 
% result_directory = '../figures/';
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
% startTime = datetime(2024, 5, 25, 16, 0, 0);
% bin_size=50;
% 
% GNSS_SDR_OBSERVABLES_process_binned(experiment, gnss_sdr_matfile, result_directory, satellitePRNs, startTime, SAVE_PLOT,bin_size)
%% SPIRENT GT PARSER
% experiment = 'CSV SPIRENT';
% spirent_matfile =  '../rinex_and_raw/spirent_GT_table.mat'; 
% result_directory = '../figures';
% satellitePRNs = [2, 3, 4, 6, 9, 12, 28];
% % startTime = datetime(1970, 1, 1, 0, 0, 0) + seconds(1400688000.0); % Tiempo GPS inicial como datetime from CSV
% startTime = datetime(2024, 5, 19, 00, 0, 0); % la semana del 25 de mayo de 2024 empezo el 19!
% 
% SPIRENT_csv_process(experiment, spirent_matfile, result_directory, satellitePRNs, startTime, SAVE_PLOT, SAVE_VIDEO_SKYPLOT)
%%
%% -------------------------- PVT ----------------------------------
% Import PVT

% % experiment = 'ISS WITH clk corr';
% load('../rinex_and_raw/PVT_ISS_long.mat');
% experiment = 'ISS WITH clk corr';
% result_directory = '../figures/';
% figure
% geoscatter(latitude, longitude, 15, valid_sats, 'filled') % 15 is marker size
% colorbar
% title('WITH clk corr - used SV')
% filename = fullfile(result_directory, ['PVT geoplot' experiment '.png']);
% saveas(gcf, filename);
% disp(['GEOPLOT: ' experiment ' plot saved to ' filename]);


%%

if CLOSE_at_END 
    close all
    disp('all CLOSED')
end