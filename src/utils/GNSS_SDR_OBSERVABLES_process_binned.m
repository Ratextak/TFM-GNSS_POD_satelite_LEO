function GNSS_SDR_OBSERVABLES_process_binned(experiment, input_matfile, result_directory, satellitePRNs, startTime, SAVE_PLOT,bin_size)
% -----------------------------------------------------------
%  Function Name:   GNSS_SDR_OBSERVABLES_process
%  Description:     Processes GNSS-SDR data from .mat file.
%  Inputs:          experiment (string)
%                   input_matfile (string): path to .mat file
%                   result_directory (string)
%                   satellitePRNs (vector): list of PRNs to plot
%                   SAVE_PLOT (boolean)
%  Outputs:         Plots for pseudorange and Doppler shift
%  Dependencies:    MATLAB R2020b or later
% -----------------------------------------------------------
 
% Load .mat file (must contain: PRN, Pseudorange_m, Carrier_Doppler_hz, RX_time)
load(input_matfile, 'PRN', 'Pseudorange_m', 'Carrier_Doppler_hz', 'RX_time');

%% REDUCE to from 264374 to 5287 (264374/50)
n_channels = size(Pseudorange_m, 1);
% Calcular el número de bloques completos
num_bins = floor(size(Pseudorange_m, 2) / bin_size);
Pseudorange_m_binned = mean(reshape(Pseudorange_m(:, 1:num_bins*bin_size), n_channels, bin_size, num_bins), 2);
Pseudorange_m_binned = squeeze(Pseudorange_m_binned);
size(Pseudorange_m_binned);

num_bins = floor(size(Carrier_Doppler_hz, 2) / bin_size);
Carrier_Doppler_hz_binned = mean(reshape(Carrier_Doppler_hz(:, 1:num_bins*bin_size), n_channels, bin_size, num_bins), 2);
Carrier_Doppler_hz_binned = squeeze(Carrier_Doppler_hz_binned);
size(Carrier_Doppler_hz_binned);

num_bins = floor(size(PRN, 2) / bin_size);
for i = 1:n_channels
    reshaped = reshape(PRN(i, 1:num_bins*bin_size), bin_size, num_bins);
    PRN_binned(i, :) = mode(reshaped, 1);  % Moda por columnas
end
%% Create time vector (1-second resolution)
% startTime = datetime(2025, 4, 25, 16, 0, 0);
duration_sec = length(PRN_binned); %5287
dateSeq = startTime + seconds(0:duration_sec-1);
endTime = datetime(2024, 5, 25, 16, 30, 0);  % <-- ajustar si es variable
%% Struct creation (for clarity/future use)
gnss_sdr.Time        = dateSeq;
gnss_sdr.SatelliteID = PRN_binned;
gnss_sdr.C1C         = Pseudorange_m_binned;
gnss_sdr.D1C         = Carrier_Doppler_hz_binned;
%% ---- PLOT ----
figure('Position', [100, 100, 800, 600]);

%% --- C1C (Pseudorange) ---
subplot(2,2,[1 2]);
hold on;
plot(gnss_sdr.Time, gnss_sdr.C1C, '.');
grid minor;
xlabel('Time');
xlim([startTime, endTime]);
% ylim([-2e7, 4e7]);
ylabel('Pseudorange (m)');
sgtitle(['Observables: ' experiment]);
hold off;

%% --- D1C (Doppler shift) ---
subplot(2,2,[3 4]);
plot(gnss_sdr.Time, gnss_sdr.D1C / 1000, '.');
grid minor;
xlabel('Time');
xlim([startTime, endTime]);
ylabel('Doppler Shift (kHz)');
sgtitle(['Observables: ' experiment]);

%% ---- SAVE FIGURE ----
if SAVE_PLOT
    if ~exist(result_directory, 'dir')
        mkdir(result_directory);
    end
    filename = fullfile(result_directory, ['results_short_' experiment '.png']);
    saveas(gcf, filename);
    disp(['Observables: ' experiment ' plot saved to ' filename]);
end

end