function SPIRENT_csv_process(experiment, input_matfile, result_directory, satellitePRNs, gps_epoch_datetime , SAVE_PLOT, SAVE_VIDEO_SKYPLOT)
% -----------------------------------------------------------
%  Function Name:   SPIRENT_process_postproc
%  Description:     Processes GNSS GT data from Spirent CSV as MAT
%  Inputs:          experiment (string)
%                   input_matfile (string): path to GT .mat file
%                   result_directory (string)
%                   satellitePRNs (vector): list of PRNs to plot
%                   SAVE_PLOT (bool)
%                   SAVE_VIDEO_SKYPLOT (bool)
%  Outputs:         Plots (Signal Strength, Doppler, Pseudorange, Skyplot)
% -----------------------------------------------------------

%% Load Ground Truth Data
load(input_matfile, 'satdataV1A1');
dataGT = satdataV1A1;
clear satdataV1A1
%%
% Suponiendo que el tiempo de referencia es el inicio de la semana GPS
% Ejemplo: GPS week starts on 2025-04-20 00:00:00 UTC (domingo)

TOW_s = dataGT.TOW_ms / 1000;
TOW_datetime = gps_epoch_datetime  + seconds(TOW_s);
%% Plot Signal Strength, Doppler, Pseudorange
figure('Position', [100, 100, 800, 600]);

% 1. Signal Strength
subplot(2,2,1); hold on;
for i = 1:length(satellitePRNs)

    filteredData = dataGT(dataGT.Sat_PRN == satellitePRNs(i), :);
    filteredData.Date = gps_epoch_datetime  + seconds(filteredData.TOW_ms/1000);
    plot(filteredData.Date, filteredData.Signal_dBGroupA,'.', ...
         'DisplayName', ['SV ' num2str(satellitePRNs(i))]);
end
xlabel('Time'); ylabel('Signal Strength (dB)'); grid minor; hold off;

% 2. Doppler
subplot(2,2,2); hold on;
for i = 1:length(satellitePRNs)
    filteredData = dataGT(dataGT.Sat_PRN == satellitePRNs(i), :);
    filteredData.Date = gps_epoch_datetime  + seconds(filteredData.TOW_ms/1000);
    plot(filteredData.Date, filteredData.Doppler_shiftGroupA/1000,'.', ...
         'DisplayName', ['SV ' num2str(satellitePRNs(i))]);
end
xlabel('Time'); ylabel('Doppler Shift (kHz)'); grid minor; hold off;

% 3. Pseudorange
subplot(2,2,[3 4]); hold on;
for i = 1:length(satellitePRNs)
    filteredData = dataGT(dataGT.Sat_PRN == satellitePRNs(i), :);
    filteredData.Date = gps_epoch_datetime  + seconds(filteredData.TOW_ms/1000);
    plot(filteredData.Date, filteredData.PRangeGroupA ,'.', ...
         'DisplayName', ['SV ' num2str(satellitePRNs(i))]);
end
xlabel('Time'); ylabel('Pseudorange (m)');
legend('Location','eastoutside');
sgtitle(['Observables: ' experiment]);
grid minor; hold off;

% Save plot
if SAVE_PLOT
    if ~exist(result_directory, 'dir'); mkdir(result_directory); end
    filename = fullfile(result_directory, ['results_' experiment '.png']);
    saveas(gcf,filename);
    disp(['Observables: ' experiment ' saved to ' filename]);
end

%% -----------------------------------------------
% ---------------------  SKYPLOT -----------------
% ------------------------------------------------
clear Allaz Allel All_TOW_ms
uniquePRNs = unique(dataGT.Sat_PRN);
uniquePRNs = uniquePRNs(1:end-3); % remove EGNOS sats
for idx = 1:length(uniquePRNs)
    thisPRN= uniquePRNs(idx);
    T_sel = dataGT(dataGT.Sat_PRN == thisPRN, :);   
    Allaz{idx,:} = rad2deg(T_sel.Azimuth);
    Allel{idx,:} = rad2deg(T_sel.Elevation);
    All_TOW_ms{idx,:} = T_sel.TOW_ms;
end

for sat_idx = 1:length(uniquePRNs)
    nFrames = length(Allaz{sat_idx});
    Allel{sat_idx}(Allel{sat_idx} <= 0) = NaN;   
    Allaz{sat_idx} = Allaz{sat_idx} +180;
    Allaz{sat_idx}(Allaz{sat_idx} > 360) = 360;
    Allaz{sat_idx}(Allaz{sat_idx} < 0) = 0;
    % sp = skyplot(Allaz{sat_idx}(1:nFrames),Allel{sat_idx}(1:nFrames));
end
%%
Allaz = Allaz';
Allel = Allel';
maxLen = max(cellfun(@length, Allaz));
Allaz_no_padding = NaN(length(Allaz), maxLen);  % Preallocate with NaNs

for i = 1:length(Allaz)
    vec = Allaz{i};
    Allaz_no_padding(i,1:length(vec)) = vec;
end

maxLen = max(cellfun(@length, Allel));
Allel_no_padding = NaN(length(Allel), maxLen);  % Preallocate with NaNs

for i = 1:length(Allel)
    vec = Allel{i};
    Allel_no_padding(i,1:length(vec)) = vec;
end
Allaz_no_padding = Allaz_no_padding';
Allel_no_padding = Allel_no_padding';
%%

figure
skyplot(Allaz_no_padding(1:6000,:),Allel_no_padding(1:6000,:),uniquePRNs)
title('SKYPLOT from CSV GT Spirent')

%% SAVE
if SAVE_PLOT
    filename = fullfile(result_directory, ['skyplot_' experiment '.png']);
    saveas(gcf, filename)
    disp(['SKYPLOT from CSV GT Spirent plot saved to ' filename])
end
%% SAVE_VIDEO_SKYPLOT
if SAVE_VIDEO_SKYPLOT
    v = VideoWriter("../figures/skyplot_csv_GT_animation.mp4");
    open(v)
    
    figure
    sp = skyplot(Allaz_no_padding(1,:),Allel_no_padding(1,:),uniquePRNs);
    for i = 1:size(Allaz_no_padding, 1)
        set(sp,AzimuthData=Allaz_no_padding(1:i,:),ElevationData=Allel_no_padding(1:i,:));
        drawnow limitrate
        frame = getframe(gcf);
        writeVideo(v, frame);
    end
    close(v);
    disp(['../figures/skyplot_csv_GT_animation.mp4 saved'])
end
