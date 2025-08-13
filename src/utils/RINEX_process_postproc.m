function RINEX_process_postproc(experiment, input_files, result_directory, satelliteIDs,SAVE_PLOT)
% -----------------------------------------------------------
%  Function Name:   RINEX_process_postproc
%  Description:     Processes GNSS data from SPIRENT log in RINEX.
%  Inputs:          experiment (string)
%                   input_files (string or cell array)
%                   result_directory (string)
%                   satelliteIDs (array of integers)
%                   SAVE_PLOT (boolean)
%  Outputs:         Visual plots of observables (S1C, D1C, C1C)
%  Dependencies:    Requires MATLAB R2020b or later.
% -----------------------------------------------------------
%

% Read RINEX data
data = rinexread(input_files);
data2 = data.GPS;
clear data

% Handle empty satelliteIDs
if isempty(satelliteIDs)
    satelliteIDs = unique(data2.SatelliteID);
end

% Get start time for x-axis limits
% startTime = min(data2.Time);
% endTime = datetime(2024,5,25,16,30,0);  % <-- ajustar si es variable

% Prepare figure
figure('Position', [100, 100, 800, 600]);

% ---- S1C subplot ----
subplot(2,2,1);
hold on;
for i = 1:length(satelliteIDs)
    filteredData = data2(data2.SatelliteID == satelliteIDs(i), :);
    plot(filteredData.Time, filteredData.S1C, '.-', 'DisplayName', ['SV ' num2str(satelliteIDs(i))]);
end
xlabel('Time');
ylabel('C/N_0 (dB-Hz)');
grid minor;
% xlim([startTime, endTime]);
hold off;

% ---- D1C subplot ----
subplot(2,2,2);
hold on;
for i = 1:length(satelliteIDs)
    filteredData = data2(data2.SatelliteID == satelliteIDs(i), :);
    plot(filteredData.Time, filteredData.D1C / 1000, '.-', 'DisplayName', ['SV ' num2str(satelliteIDs(i))]);
end
xlabel('Time');
ylabel('Doppler Shift (kHz)');
grid minor;
% xlim([startTime, endTime]);
hold off;

% ---- C1C subplot ----
subplot(2,2,[3 4]);
hold on;
for i = 1:length(satelliteIDs)
    filteredData = data2(data2.SatelliteID == satelliteIDs(i), :);
    plot(filteredData.Time, filteredData.C1C, '.', 'DisplayName', ['SV ' num2str(satelliteIDs(i))]);
end
xlabel('Time');
ylabel('Pseudorange (m)');
grid minor;
% xlim([startTime, endTime]);
legend('Location','eastoutside');
sgtitle(['RINEX Observables: ' experiment]);
hold off;

% ---- Save plot if requested ----
if SAVE_PLOT
    if ~exist(result_directory, 'dir')
        mkdir(result_directory);
    end
    filename = fullfile(result_directory, ['results_short_' experiment '.png']);
    saveas(gcf, filename);
    disp(['RINEX: ' experiment ' plot saved to ' filename]);
end

end