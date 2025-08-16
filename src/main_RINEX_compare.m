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
options.process_individual = true;
options.process_comparision = true;
% COMPARISIONS
compare_pairs = { ...
    {1,2,'GPS'}, ... % Basic vs Advanced GPS
    {1,3,'GPS'}, ... % Basic vs MOSAIC GPS
    {2,3,'GPS'}, ... % Advanced vs MOSAIC GPS
    {1,2,'Galileo'}, ... % Basic vs Advanced Galileo
    {1,3,'Galileo'}, ... % Basic vs MOSAIC Galileo
    {2,3,'Galileo'}      % Advanced vs MOSAIC Galileo
};

base_path_data   = fullfile('C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\repositorios\gnss-flex\data\CEDEA');   % datos
results_base_dir = fullfile('C:\Users\User\OneDrive - Universidad Politécnica de Madrid\Documentos\repositorios\gnss-flex\results\plots_OBS');  % resultados

% RINEX por receptor (archivos originales y .mat preprocesados)
receptors = struct( ...
    'name', {'Flight 2 Basic Rx', 'Flight 2 Advanced Rx', 'Flight 2 MOSAIC-X5'}, ...
    'folder', { ...
        fullfile('vuelo_2_eme_rx_basic'), ...
        fullfile('vuelo_2_eme_rx_adv'), ...
        'vuelo_2_mosaicX5' ...
    }, ...
    'file_obs', {'run_2025-02-05_00-25-57/GSDR036a25.25O', 'run_2025-07-05_00-18-38/GSDR186a18.25O', '1ant1015.obs'}, ...  % RINEX observation
    'file_nav', {'run_2025-02-05_00-25-57/GSDR036a25.25P', 'run_2025-07-05_00-18-38/GSDR186a18.25P', '1ant1015_gps.nav'}, ...  % RINEX navigation
    'file_mat', {'vuelo_2_eme_rx_basic.mat', 'vuelo_2_eme_rx_adv.mat', 'vuelo_2_mosaicX5.mat'}, ... % struct ya cargado
    'result_dir', {''} ...
);

%% ---------------- Process Individual RINEX gor GPS and GAL ----------------
if options.process_individual
    for i = 1:numel(receptors)
        exp_name = receptors(i).name;
        mat_file = fullfile(base_path_data, receptors(i).folder, receptors(i).file_mat);
        out_dir  = fullfile(results_base_dir, receptors(i).result_dir);
        satellitePRNs = [];  % todos
    
        if ~isfile(mat_file)
            warning('Falta archivo para "%s": %s', exp_name, mat_file);
            continue
        end
    
        if ~isfolder(out_dir), mkdir(out_dir); end
    
        fprintf('[%s] Procesando RINEX...\n', exp_name);
    
        % Procesar ambas constelaciones
        for constellation = ["GPS", "Galileo"]
            try
                RINEX_process_postproc(exp_name, mat_file, out_dir, satellitePRNs, options.SAVE_PLOT, char(constellation));
            catch ME
                warning('No se pudo procesar %s para %s: %s', exp_name, constellation, ME.message);
            end
        end
    end
end


%% ---------------- Compare RINEX Between Receptors (usar .mat si existe) ---------
if options.process_comparision
    for k = 1:numel(compare_pairs)
        idx1 = compare_pairs{k}{1};
        idx2 = compare_pairs{k}{2};
        constellation  = compare_pairs{k}{3};
    
        % Nombres limpios de receptores para carpeta
        name1_clean = regexprep(receptors(idx1).name, '\W', '_'); 
        name2_clean = regexprep(receptors(idx2).name, '\W', '_'); 
    
        % Carpeta de resultados automática por par
        out_dir  = fullfile(results_base_dir, receptors(i).result_dir);
        if ~isfolder(out_dir), mkdir(out_dir); end
    
        experiment = sprintf('Flight 2 - %s vs %s', receptors(idx1).name, receptors(idx2).name);
    
        % ---------------- Determinar qué cargar: .mat o .obs ----------------
        mat_file1 = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_mat);
        mat_file2 = fullfile(base_path_data, receptors(idx2).folder, receptors(idx2).file_mat);
    
        if isfile(mat_file1) && isfile(mat_file2)
            % Cargar structs desde .mat
            data1 = load(mat_file1); data1 = data1.rinexData;
            data2 = load(mat_file2); data2 = data2.rinexData;
            fprintf('[%s] Comparando usando .mat preprocesado (%s)...\n', experiment, constellation);
            compare_rinex_observables(experiment, data1, data2, out_dir, [], options.SAVE_PLOT, constellation);
        else
            % Caer a los archivos .obs originales
            file1 = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_obs);
            file2 = fullfile(base_path_data, receptors(idx2).folder, receptors(idx2).file_obs);
            if ~isfile(file1) || ~isfile(file2)
                warning('Falta archivo para comparación: %s', experiment);
                continue
            end
            fprintf('[%s] Comparando usando .obs original (%s)...\n', experiment, constellation);
            compare_rinex_observables(experiment, file1, file2, out_dir, [], options.SAVE_PLOT, constellation);
        end
    end
end

%% ---------------- Skyplot por Receptor/RINEX ----------------
idx1=2;
% Cargar navegación
file1_nav = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_nav);
rinexData = rinexread(file1_nav);

navData_GPS = rinexData.GPS;
navData_Galileo = rinexData.Galileo;
[~,satIdx] = unique(navData_Galileo.SatelliteID);
navData_Galileo = navData_Galileo(satIdx,:);    
% Época de interés
t = navData_GPS.Time(1);
% t = datetime(2025,07,17,11,30,44);


% Posiciones satélite
[satPos_GPS,~,satID_GPS] = gnssconstellation(t,navData_GPS,GNSSFileType="RINEX");
[satPos_Gal,~,satID_Gal] = gnssconstellation(t,navData_Galileo,GNSSFileType="RINEX");

% Pos receptor y máscara
recPos = [40.3895, -3.7474, 0]; % [lat deg, lon deg, alt m]
maskAngle = 1;

% Look angles
[az_GPS,el_GPS,vis_GPS] = lookangles(recPos,satPos_GPS,maskAngle);
[az_Gal,el_Gal,vis_Gal] = lookangles(recPos,satPos_Gal,maskAngle);

fprintf('%d GPS satellites visible at %s.\n',nnz(vis_GPS),t)
fprintf('%d Galileo satellites visible at %s.\n',nnz(vis_Gal),t)

% Unir datos GPS + Galileo visibles
az_all = [az_GPS(vis_GPS); az_Gal(vis_Gal)];
el_all = [el_GPS(vis_GPS); el_Gal(vis_Gal)];
id_all = [satID_GPS(vis_GPS); satID_Gal(vis_Gal)];

% Etiquetas de grupo
group_all = [repmat("GPS",nnz(vis_GPS),1); repmat("Galileo",nnz(vis_Gal),1)];
group_all = categorical(group_all);

% Skyplot combinado
figure
skyplot(az_all, el_all, id_all, MaskElevation=maskAngle, GroupData=group_all)
legend('GPS','Galileo')
title(sprintf('Skyplot at CEDEA; UTC %s', datetime(t)))

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
