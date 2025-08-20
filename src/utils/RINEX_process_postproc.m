function RINEX_process_postproc(experiment, input_files, result_directory, satelliteIDs, events, SAVE_PLOT, constellation)
% -----------------------------------------------------------
%  Function Name:   RINEX_process_postproc
%  Description:     Processes GNSS data from RINEX files or .mat structs.
%  Inputs:
%     experiment (string)
%     input_files (string, cell array, or struct)
%     result_directory (string)
%     satelliteIDs (array of integers)
%     SAVE_PLOT (boolean)
%     constellation (string, optional: 'GPS' or 'Galileo')
% -----------------------------------------------------------

if nargin < 7
    constellation = 'GPS';
end

% ---------------- Load data ----------------
if isstruct(input_files)
    data = input_files;  % Already loaded struct (from .mat)
elseif ischar(input_files) && endsWith(input_files, '.mat')
    tmp = load(input_files);
    fn = fieldnames(tmp);
    if numel(fn) ~= 1
        error('Expected one variable inside .mat, found %d', numel(fn));
    end
    data = tmp.(fn{1});
elseif ischar(input_files) || iscell(input_files)
    data = rinexread(input_files);
else
    error('Unsupported input type.');
end

% Select constellation
if isfield(data, constellation)
    data2 = data.(constellation);
else
    error('Constellation "%s" not found in data.', constellation);
end
clear data

% Handle empty satelliteIDs
if isempty(satelliteIDs)
    satelliteIDs = unique(data2.SatelliteID);
end

% Prepare figure
figure('Position', [100, 100, 800, 600]);

% ---- Sx subplot (C/N0) ----
subplot(2,2,1); hold on;
cn0_options = {'S1C','S1B','S1X'};
cn0_field = intersect(cn0_options, data2.Properties.VariableNames);
for i = 1:length(satelliteIDs)
    filteredData = data2(data2.SatelliteID == satelliteIDs(i), :);
    if isempty(cn0_field), continue; end
    plot(filteredData.Time, filteredData.(cn0_field{1}), '.-', 'DisplayName', ['SV ' num2str(satelliteIDs(i))]);
end
for i = 1:length(events)
    xline(events(i).Time, '--k', events(i).Label);
end
xlabel('Time'); ylabel('C/N_0 (dB-Hz)'); grid minor; hold off;

% ---- Doppler subplot ----
subplot(2,2,2); hold on;
doppler_options = {'D1C','D1B','D1X'};
doppler_field = intersect(doppler_options, data2.Properties.VariableNames);
for i = 1:length(satelliteIDs)
    filteredData = data2(data2.SatelliteID == satelliteIDs(i), :);
    if isempty(doppler_field), continue; end
    plot(filteredData.Time, filteredData.(doppler_field{1}) / 1000, '.-', 'DisplayName', ['SV ' num2str(satelliteIDs(i))]);
end
for i = 1:length(events)
    xline(events(i).Time, '--k', events(i).Label);
end
xlabel('Time'); ylabel('Doppler Shift (kHz)'); grid minor; hold off;

% ---- Pseudorange subplot ----
subplot(2,2,[3 4]); hold on;
pr_options = {'C1C','C1B','C1X'};
pr_field = intersect(pr_options, data2.Properties.VariableNames);
for i = 1:length(satelliteIDs)
    filteredData = data2(data2.SatelliteID == satelliteIDs(i), :);
    if isempty(pr_field), continue; end
    plot(filteredData.Time, filteredData.(pr_field{1}), '.', 'DisplayName', ['SV ' num2str(satelliteIDs(i))]);
end
for i = 1:length(events)
    xline(events(i).Time, '--k', events(i).Label);
end
xlabel('Time'); ylabel('Pseudorange (m)'); grid minor;
legend('Location','eastoutside');
sgtitle(['RINEX Observables: ' experiment ' - ' constellation]);
hold off;

% ---- Save plot if requested ----
if SAVE_PLOT
    if ~exist(result_directory, 'dir')
        mkdir(result_directory);
    end
    filename = fullfile(result_directory, [experiment '_' constellation '.png']);
    saveas(gcf, filename);
    disp(['RINEX: ' experiment ' plot saved to ' filename]);
end

end
