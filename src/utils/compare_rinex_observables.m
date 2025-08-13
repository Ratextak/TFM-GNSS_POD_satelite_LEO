function compare_rinex_observables(experiment, rinex1, rinex2, result_directory, satelliteIDs, SAVE_PLOT, constellation)
% -----------------------------------------------------------
%  Function Name:   compare_rinex_observables
%  Description:     Compares GNSS observables from two RINEX sources
%  Inputs:
%     experiment (string)
%     rinex1, rinex2 (string): paths to RINEX files
%     result_directory (string)
%     satelliteIDs (array of integers)
%     SAVE_PLOT (boolean)
%     constellation (string): 'GPS', 'Galileo'
% -----------------------------------------------------------

if nargin < 7
    constellation = 'GPS';  % Default
end

% Read RINEX data
rinexData1 = rinexread(rinex1);
rinexData2 = rinexread(rinex2);

if ~isfield(rinexData1, constellation) || ~isfield(rinexData2, constellation)
    error(['Constellation "' constellation '" not found in one of the RINEX files.']);
end

data1 = rinexData1.(constellation);
data2 = rinexData2.(constellation);

switch constellation
    case 'GPS'
        data1 = rinexread(rinex1).GPS;
        data2 = rinexread(rinex2).GPS;
        obs_fields = {'S1C', 'D1C', 'C1C'};
    case 'Galileo'
        data1 = rinexread(rinex1).Galileo;
        data2 = rinexread(rinex2).Galileo;
        obs_fields = {'S1B', 'D1B', 'C1B'};
    otherwise
        error('Constellation not supported or data not present in RINEX.');
end



% Determine satellites to compare
if isempty(satelliteIDs)
    satelliteIDs = intersect(unique(data1.SatelliteID), unique(data2.SatelliteID));
end

% Initialize RMSE results
rmse_table = table('Size', [length(satelliteIDs), 4], ...
                   'VariableTypes', {'double','double','double','double'}, ...
                   'VariableNames', {'SV','RMSE_S1C','RMSE_D1C_Hz','RMSE_C1C_m'});

% Initialize error arrays
all_err_s1c = [];
all_err_d1c = [];
all_err_c1c = [];

% Create figure for time series errors
f1 = figure('Name','Observable Errors','WindowState','maximized');

for idx = 1:length(satelliteIDs)
    sv = satelliteIDs(idx);
    d1 = data1(data1.SatelliteID == sv, :);
    d2 = data2(data2.SatelliteID == sv, :);
    
    [t_common, ia, ib] = intersect(d1.Time, d2.Time);
    
    err_s1c = d1.S1C(ia) - d2.S1C(ib);
    err_d1c = d1.D1C(ia) - d2.D1C(ib);
    err_c1c = d1.C1C(ia) - d2.C1C(ib);
    
    all_err_s1c = [all_err_s1c; err_s1c];
    all_err_d1c = [all_err_d1c; err_d1c];
    all_err_c1c = [all_err_c1c; err_c1c];

    rmse_table.SV(idx) = sv;
    rmse_table.RMSE_S1C(idx) = sqrt(mean(err_s1c.^2, 'omitnan'));
    rmse_table.RMSE_D1C_Hz(idx) = sqrt(mean(err_d1c.^2, 'omitnan'));
    rmse_table.RMSE_C1C_m(idx) = sqrt(mean(err_c1c.^2, 'omitnan'));

    % ---- Plot time series errors ----
    subplot(3,1,1); hold on;
    plot(t_common, err_s1c, '.-', 'DisplayName', ['SV ' num2str(sv)]);

    subplot(3,1,2); hold on;
    plot(t_common, err_d1c, '.-', 'DisplayName', ['SV ' num2str(sv)]);

    subplot(3,1,3); hold on;
    plot(t_common, err_c1c, '.-', 'DisplayName', ['SV ' num2str(sv)]);
end

% Finalize time series plots
subplot(3,1,1);
ylabel('\Delta S1C (dB-Hz)'); title('Error in S1C'); grid minor; legend('Location','eastoutside');

subplot(3,1,2);
ylabel('\Delta D1C (Hz)'); title('Error in D1C'); grid minor;

subplot(3,1,3);
ylabel('\Delta C1C (m)'); xlabel('Time'); title('Error in C1C'); grid minor;

sgtitle(['Observable Errors: ' experiment ' - ' constellation]);

% Save time series plot
if SAVE_PLOT
    if ~exist(result_directory, 'dir')
        mkdir(result_directory);
    end
    saveas(f1, fullfile(result_directory, ['errors_rinex_' experiment '_' constellation '.png']));
end

% ---- Histogram Plot ----
f2 = figure('Name','Error Histograms','WindowState','maximized');

subplot(3,1,1);
histogram(all_err_s1c, 'BinWidth', 0.2,'Normalization','probability'); grid on;
xlabel('\Delta S1C (dB-Hz)'); ylabel('Count'); title('Histogram of S1C Error');

subplot(3,1,2);
histogram(all_err_d1c, 'BinWidth', 0.2,'Normalization','probability'); grid on;
xlabel('\Delta D1C (Hz)'); ylabel('Count'); title('Histogram of D1C Error');

subplot(3,1,3);
histogram(all_err_c1c, 'BinWidth', 0.2,'Normalization','probability'); grid on;
xlabel('\Delta C1C (m)'); ylabel('Count'); title('Histogram of C1C Error');

sgtitle(['Error Histograms: ' experiment ' - ' constellation]);

% Save histogram figure and table
if SAVE_PLOT
    saveas(f2, fullfile(result_directory, ['histogram_rinex_' experiment '_' constellation '.png']));
    writetable(rmse_table, fullfile(result_directory, ['rmse_rinex_' experiment '_' constellation '.csv']));
    disp(['Saved plots and RMSE table to ' result_directory]);
end

end
