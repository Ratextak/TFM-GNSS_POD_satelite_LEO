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
options.CLOSE_at_END = 1;
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

base_path_data   = fullfile('..\data\CEDEA');   % datos
results_base_dir = fullfile('..\results\plots_OBS');  % resultados

% RINEX por receptor (archivos originales y .mat preprocesados)
receptors = struct( ...
    'name', {'Flight 2 Basic Rx', 'Flight 2 Advanced Rx', 'Flight 2 MOSAIC-X5'}, ...
    'folder', { ...
        fullfile('vuelo_2_eme_rx_basic'), ...
        fullfile('vuelo_2_eme_rx_adv'), ...
        'vuelo_2_mosaicX5' ...
    }, ...
    'file_obs', {'run_2025-02-05_00-25-57/GSDR036a25.25O', 'run_2025-07-05_00-18-38/GSDR186a18.25O', '1ant1015.obs'}, ...  % RINEX observation
    'file_nav', {'run_2025-02-05_00-25-57/GSDR036a25.25P', 'run_2025-07-05_00-18-38/GSDR186a18.25P', '1ant1015_galileo_gps_generated.nav'}, ...  % RINEX navigation
    'file_PVTmat', {'PVTvuelo_2_eme_rx_basic.mat', 'PVTvuelo_2_eme_rx_adv.mat', 'PVTvuelo_2_mosaicX5.mat'}, ...  % PVT
    'file_RINEXmat', {'RINEXvuelo_2_eme_rx_basic.mat', 'RINEXvuelo_2_eme_rx_adv.mat', 'RINEXvuelo_2_mosaicX5.mat'}, ... % struct ya cargado
    'result_dir', {''} ...
);

%% ---------------- Process Individual RINEX gor GPS and GAL ----------------
if options.process_individual
    for i = 1:numel(receptors)
        exp_name = receptors(i).name;
        mat_file = fullfile(base_path_data, receptors(i).folder, receptors(i).file_RINEXmat);
        out_dir  = fullfile(results_base_dir, receptors(i).result_dir);
        satellitePRNs = [];  % todos
    
        if ~isfile(mat_file)
            warning('Falta archivo .MAT para "%s": %s', exp_name, mat_file);
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
        mat_file1 = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_RINEXmat);
        mat_file2 = fullfile(base_path_data, receptors(idx2).folder, receptors(idx2).file_RINEXmat);
    
        if isfile(mat_file1) && isfile(mat_file2)
            % Cargar structs desde .mat
            data1 = load(mat_file1); data1 = data1.RinexData;
            data2 = load(mat_file2); data2 = data2.RinexData;
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

%% ---------------- Skyplot por Receptor/RINEX con Trayectoria (decimado) ----------------
for idx1 =1:numel(receptors)
    step = 100; % tomar 1 de cada 10 posiciones
    
    % Archivos
    file1_nav = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_nav);
    file1_pvt = fullfile(base_path_data, receptors(idx1).folder, receptors(idx1).file_PVTmat);
    file1_pvt_data = load(file1_pvt);
    
    % Navegación
    rinexData     = rinexread(file1_nav);
    navData_GPS   = rinexData.GPS;
    navData_Gal   = rinexData.Galileo;
    [~,satIdx]    = unique(navData_Gal.SatelliteID);
    navData_Gal   = navData_Gal(satIdx,:);
    
    % Semana GPS y TOW del receptor
    Week     = file1_pvt_data.PVTData.Week;
    TOW_ms   = file1_pvt_data.PVTData.TOW;
    
    gpsEpoch = datetime(1980,1,6,0,0,0,'TimeZone','UTC');
    timeVec  = gpsEpoch + calweeks(Week) + seconds(TOW_ms/1000);
    
    % Pos receptor (trayectoria PVT)
    recLat = file1_pvt_data.PVTData.Lat;
    recLon = file1_pvt_data.PVTData.Lon;
    recHgt = file1_pvt_data.PVTData.Height;
    
    % --- Decimación ---
    timeVecDec = timeVec(1:step:end);
    recLatDec  = recLat(1:step:end);
    recLonDec  = recLon(1:step:end);
    recHgtDec  = recHgt(1:step:end);
    numTimesDec = numel(timeVecDec);
    
    maskAngle = 5; % elevación mínima
    
    % Conjunto de todos los PRNs posibles
    allPRN = unique([navData_GPS.SatelliteID; navData_Gal.SatelliteID]);
    numSats = numel(allPRN);
    
    % Inicializar matrices
    az_all = NaN(numTimesDec, numSats);
    el_all = NaN(numTimesDec, numSats);
    grp_all = strings(numSats,1);
    
    % === Bucle temporal decimado ===
    for k = 1:numTimesDec
        t = timeVecDec(k);
        recPos = [recLatDec(k), recLonDec(k), recHgtDec(k)];
    
        % Posiciones de satélites
        [satPos_GPS,~,satID_GPS] = gnssconstellation(t, navData_GPS, GNSSFileType="RINEX");
        [satPos_Gal,~,satID_Gal] = gnssconstellation(t, navData_Gal, GNSSFileType="RINEX");
    
        % Look angles
        [azG, elG, visG] = lookangles(recPos, satPos_GPS, maskAngle);
        [azE, elE, visE] = lookangles(recPos, satPos_Gal, maskAngle);
    
        % Llenar columnas por PRN (NaN si no visible)
        for i = 1:numel(satID_GPS)
            idxCol = find(allPRN == satID_GPS(i));
            if visG(i)
                az_all(k, idxCol) = azG(i);
                el_all(k, idxCol) = elG(i);
            end
            grp_all(idxCol) = "GPS";
        end
        for i = 1:numel(satID_Gal)
            idxCol = find(allPRN == satID_Gal(i));
            if visE(i)
                az_all(k, idxCol) = azE(i);
                el_all(k, idxCol) = elE(i);
            end
            grp_all(idxCol) = "Galileo";
        end
    end
    
    grp_all = categorical(grp_all);
    
    % === Guardar variables en .mat ===
    saveFile = fullfile(base_path_data, 'SkyplotTrajectory_Decimated.mat');
    save(saveFile, 'az_all', 'el_all', 'allPRN', 'grp_all', 'timeVecDec');
    fprintf('Variables guardadas en: %s\n', saveFile);
    
    % === Skyplot final (última posición) ===
    figure('Visible','on') % No mostrar ventana
    skyplot(az_all, el_all, allPRN, MaskElevation=maskAngle, GroupData=grp_all);
    title(sprintf('%s CEDEA (%s – %s UTC)', ...
            receptors(idx1).name, datetime(timeVecDec(1)), datetime(timeVecDec(end))))
    legend('GPS','Galileo')
    % Guardar solo la última imagen
    pngFile = fullfile(base_path_data, [receptors(idx1).name '_skyplot.png']);
    saveas(gcf, pngFile);
    fprintf('Skyplot final guardado en: %s\n', pngFile);
end
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
