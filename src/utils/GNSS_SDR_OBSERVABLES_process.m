function GNSS_SDR_OBSERVABLES_process(experiment, input_matfile, result_directory, satellitePRNs, startTime, SAVE_PLOT)
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

%% Create time vector (1-second resolution)
duration_sec = length(PRN)
dateSeq = startTime + seconds(0:duration_sec-1);
endTime = datetime(2024, 5, 25, 17, 30, 0);  % <-- ajustar si es variable
%% Struct creation (for clarity/future use)
gnss_sdr.Time        = dateSeq;
gnss_sdr.SatelliteID = PRN;
gnss_sdr.C1C         = Pseudorange_m;
gnss_sdr.D1C         = Carrier_Doppler_hz;
%% ---- PLOT ----
figure('Position', [100, 100, 800, 600]);

%% --- C1C (Pseudorange) ---
subplot(2,2,[1 2]);
hold on;
plot(gnss_sdr.Time, gnss_sdr.C1C, '.');
grid minor;
xlabel('Time');
xlim([startTime, endTime]);
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