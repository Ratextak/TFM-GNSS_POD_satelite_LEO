%% -----------------------------------------------------------
% Script Name:   main_compare_RINEX.m
% Description:   Processes GNSS RINEX and PVT from multiple sources
% Author:        gomezlma@inta.es
% Date:          2025-07-28
% Inputs:        RINEX files.
% Outputs:       Processed GNSS data and plots.
% Dependencies:  Requires MATLAB R2020b or later, RINEX_process_postproc, compare_rinex_observables.
%% -----------------------------------------------------------

close all; clearvars; clc;
% Add source folder to path
addpath(genpath('C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\repositorios\gnss-flex\src'));
%% ---------------- Paths & Options -------------------------
options.SAVE_PLOT = 1;
options.CLOSE_at_END = 0;
options.SAVE_VIDEO_SKYPLOT = 0;

base_path_data   = fullfile('C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\repositorios\gnss-flex\data\CEDEA');   % datos
results_base_dir = fullfile('C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\repositorios\gnss-flex\results\plots_OBS');  % resultados

% RINEX por receptor (archivos originales y .mat preprocesados)
receptors = struct( ...
    'name', {'SCRAB II Basic Rx', 'SCRAB II Advanced Rx', 'SCRAB II MOSAIC-X5'}, ...
    'folder', { ...
        fullfile('vuelo_2_eme_rx_basic'), ...
        fullfile('vuelo_2_eme_rx_adv'), ...
        'vuelo_2_mosaicX5' ...
    }, ...
    'file_obs', {'run_2025-02-05_00-25-57/GSDR036a25.25O', 'run_2025-07-05_00-18-38/GSDR186a18.25O', '1ant1015.obs'}, ...  % RINEX original
    'file_mat', {'vuelo_2_eme_rx_basic.mat', 'vuelo_2_eme_rx_adv.mat', 'vuelo_2_mosaicX5.mat'}, ... % struct ya cargado
    'result_dir', {'figures_rx_basic', 'figures_rx_advanced', 'figures_mosaicX5'} ...
);

%% ---------------- Process Individual RINEX ----------------
for i = 1:numel(receptors)
    exp_name = receptors(i).name;
    obs_file = fullfile(base_path_data, receptors(i).folder, receptors(i).file_obs);
    out_dir  = fullfile(results_base_dir, receptors(i).result_dir);
    satellitePRNs = [];  % todos

    if ~isfile(obs_file)
        warning('Falta archivo para "%s": %s', exp_name, obs_file);
        continue
    end

    if ~isfolder(out_dir), mkdir(out_dir); end

    fprintf('[%s] Procesando RINEX...\n', exp_name);
    RINEX_process_postproc(exp_name, obs_file, out_dir, satellitePRNs, options.SAVE_PLOT);
end

%% ---------------- Compare RINEX Between Receptors (usar .mat si existe) ---------

compare_pairs = { ...
    {1,2,'GPS'}, ... % Basic vs Advanced GPS
    {1,3,'GPS'}, ... % Basic vs MOSAIC GPS
    {2,3,'GPS'}, ... % Advanced vs MOSAIC GPS
    {1,2,'Galileo'}, ... % Basic vs Advanced Galileo
    {1,3,'Galileo'}, ... % Basic vs MOSAIC Galileo
    {2,3,'Galileo'}      % Advanced vs MOSAIC Galileo
};

for k = 1:numel(compare_pairs)
    idx1 = compare_pairs{k}{1};
    idx2 = compare_pairs{k}{2};
    constellation  = compare_pairs{k}{3};

    % Nombres limpios de receptores para carpeta
    name1_clean = regexprep(receptors(idx1).name, '\W', '_'); 
    name2_clean = regexprep(receptors(idx2).name, '\W', '_'); 

    % Carpeta de resultados automática por par
    result_dir_cmp = fullfile(results_base_dir, ...
        sprintf('figures_comparision_%s_vs_%s_%s', name1_clean, name2_clean, constellation));
    if ~isfolder(result_dir_cmp), mkdir(result_dir_cmp); end

    experiment = sprintf('SCRAB II flight - %s vs %s', receptors(idx1).name, receptors(idx2).name);

    % ---------------- Determinar qué cargar: .mat o .obs ----------------
    mat_file1 = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_mat);
    mat_file2 = fullfile(base_path_data, receptors(idx2).folder, receptors(idx2).file_mat);

    if isfile(mat_file1) && isfile(mat_file2)
        % Cargar structs desde .mat
        data1 = load(mat_file1); data1 = data1.rinexData;
        data2 = load(mat_file2); data2 = data2.rinexData;
        fprintf('[%s] Comparando usando .mat preprocesado (%s)...\n', experiment, constellation);
        compare_rinex_observables(experiment, data1, data2, result_dir_cmp, [], options.SAVE_PLOT, constellation);
    else
        % Caer a los archivos .obs originales
        file1 = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_obs);
        file2 = fullfile(base_path_data, receptors(idx2).folder, receptors(idx2).file_obs);
        if ~isfile(file1) || ~isfile(file2)
            warning('Falta archivo para comparación: %s', experiment);
            continue
        end
        fprintf('[%s] Comparando usando .obs original (%s)...\n', experiment, constellation);
        compare_rinex_observables(experiment, file1, file2, result_dir_cmp, [], options.SAVE_PLOT, constellation);
    end
end

%% ---------------- Skyplot por Receptor/RINEX ----------------
% TODO
%% ---------------- Optional GNSS-SDR / SPIRENT ----------------
% TODO
% GNSS_SDR_OBSERVABLES_process_binned(...)
% SPIRENT_csv_process(...)

%% ---------------- End script -----------------------------
if options.CLOSE_at_END
    close all;
    disp('All figures closed');
end
disp('main_compare_RINEX finished successfully');
