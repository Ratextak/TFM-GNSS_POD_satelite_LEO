function compare_rinex_observables(experiment, rinex1, rinex2, result_directory, satelliteIDs, events, SAVE_PLOT, constellation)
% -----------------------------------------------------------
%  Function Name:   compare_rinex_observables
%  Description:     Compares GNSS observables from two RINEX sources
%  Inputs:
%     experiment (string)
%     rinex1, rinex2 (string or struct): paths to RINEX files or already loaded data
%     result_directory (string)
%     satelliteIDs (array of integers)
%     SAVE_PLOT (boolean)
%     constellation (string): 'GPS', 'Galileo'
% -----------------------------------------------------------

if nargin < 8
    constellation = 'GPS';  % Default
end

%% ---------------- Read or use already loaded RINEX ----------------
if ischar(rinex1) || isstring(rinex1)
    rinexData1 = rinexread(rinex1);
else
    rinexData1 = rinex1;
end

if ischar(rinex2) || isstring(rinex2)
    rinexData2 = rinexread(rinex2);
else
    rinexData2 = rinex2;
end

if ~isfield(rinexData1, constellation) || ~isfield(rinexData2, constellation)
    error(['Constellation "' constellation '" not found in one of the RINEX files.']);
end

data1 = rinexData1.(constellation);
data2 = rinexData2.(constellation);

%% ---------------- Determine satellites to compare ----------------
if isempty(satelliteIDs)
    satelliteIDs = intersect(unique(data1.SatelliteID), unique(data2.SatelliteID));
end

%% ---------------- Detect observable fields ----------------
cn0_field = intersect({'S1C','S1B','S6C','S5Q','S7Q'}, data1.Properties.VariableNames);
doppler_field = intersect({'D1C','D1B','D6C','D5Q','D7Q'}, data1.Properties.VariableNames);
pr_field = intersect({'C1C','C1B','C6C','C5Q','C7Q'}, data1.Properties.VariableNames);

if isempty(cn0_field) || isempty(doppler_field) || isempty(pr_field)
    error('No se encuentran los campos de observables en data1');
end

%% ---------------- Initialize RMSE and error arrays ----------------
rmse_table = table('Size', [length(satelliteIDs), 4], ...
                   'VariableTypes', {'double','double','double','double'}, ...
                   'VariableNames', {'SV','RMSE_S1C','RMSE_D1C_Hz','RMSE_C1C_m'});

all_err_cn0 = [];
all_err_doppler = [];
all_err_pr = [];

f1 = figure('Name','Observable Errors','WindowState','maximized');

%% ---------------- Create figure for time series ----------------

for idx = 1:length(satelliteIDs)
    sv = satelliteIDs(idx);
    d1 = data1(data1.SatelliteID == sv, :);
    d2 = data2(data2.SatelliteID == sv, :);

    [t_common, ia, ib] = intersect(d1.Time, d2.Time);

    % ---- Detect CN0, Doppler, Pseudorange fields para cada table ----
    cn0_field1 = intersect({'S1C','S1B','S1X'}, d1.Properties.VariableNames);
    cn0_field2 = intersect({'S1C','S1B','S1X'}, d2.Properties.VariableNames);
    
    doppler_field1 = intersect({'D1C','D1B','D1X'}, d1.Properties.VariableNames);
    doppler_field2 = intersect({'D1C','D1B','D1X'}, d2.Properties.VariableNames);
    
    pr_field1 = intersect({'C1C','C1B','C1X'}, d1.Properties.VariableNames);
    pr_field2 = intersect({'C1C','C1B','C1X'}, d2.Properties.VariableNames);
    
    % ---- Usar los que existen ----
    err_cn0     = d1.(cn0_field1{1})(ia) - d2.(cn0_field2{1})(ib);
    err_doppler = d1.(doppler_field1{1})(ia) - d2.(doppler_field2{1})(ib);
    err_pr      = d1.(pr_field1{1})(ia) - d2.(pr_field2{1})(ib);

    % ---------------- Accumulate errors ----------------
    all_err_cn0 = [all_err_cn0; err_cn0];
    all_err_doppler = [all_err_doppler; err_doppler];
    all_err_pr = [all_err_pr; err_pr];

    % ---------------- Calculate RMSE ----------------
    rmse_table.SV(idx) = sv;
    rmse_table.RMSE_S1C(idx) = sqrt(mean(err_cn0.^2,'omitnan'));
    rmse_table.RMSE_D1C_Hz(idx) = sqrt(mean(err_doppler.^2,'omitnan'));
    rmse_table.RMSE_C1C_m(idx) = sqrt(mean(err_pr.^2,'omitnan'));

    % ---------------- Plot time series ----------------
    subplot(3,1,1); hold on; plot(t_common, err_cn0, '.-', 'DisplayName', ['SV ' num2str(sv)]);
    subplot(3,1,2); hold on; plot(t_common, err_doppler, '.-', 'DisplayName', ['SV ' num2str(sv)]);
    subplot(3,1,3); hold on; plot(t_common, err_pr, '.-', 'DisplayName', ['SV ' num2str(sv)]);
end

%% ---------------- Finalize time series plots ----------------
subplot(3,1,1); ylabel('\Delta C/N0 (dB-Hz)'); title('Error in C/N0'); grid minor; legend('Location','eastoutside');
for i = 1:length(events)
    xline(events(i).Time, '--k', events(i).Label);
end
subplot(3,1,2); ylabel('\Delta Doppler (Hz)'); title('Error in Doppler'); grid minor;
for i = 1:length(events)
    xline(events(i).Time, '--k', events(i).Label);
end
subplot(3,1,3); ylabel('\Delta Pseudorange (m)'); xlabel('Time'); title('Error in Pseudorange'); grid minor;
sgtitle(['Observable Errors: ' experiment ' - ' constellation]);
for i = 1:length(events)
    xline(events(i).Time, '--k', events(i).Label);
end
if SAVE_PLOT
    if ~exist(result_directory, 'dir'), mkdir(result_directory); end
    saveas(f1, fullfile(result_directory, ['errors_rinex_' experiment '_' constellation '.png']));
end

%% ---------------- Histogram plots ----------------
f2 = figure('Name','Error Histograms','WindowState','maximized');

subplot(3,1,1); histogram(all_err_cn0,'Normalization','probability'); grid on;
xlabel('\Delta C/N0 (dB-Hz)'); ylabel('Probability'); title('Histogram of C/N0 Error');

subplot(3,1,2); histogram(all_err_doppler,'Normalization','probability'); grid on;
xlabel('\Delta Doppler (Hz)'); ylabel('Probability'); title('Histogram of Doppler Error');

subplot(3,1,3); histogram(all_err_pr,'Normalization','probability'); grid on;
xlabel('\Delta Pseudorange (m)'); ylabel('Probability'); title('Histogram of Pseudorange Error');

sgtitle(['Error Histograms: ' experiment ' - ' constellation]);

%% ---------------- Save histogram and RMSE ----------------
if SAVE_PLOT
    saveas(f2, fullfile(result_directory, ['histogram_rinex_' experiment '_' constellation '.png']));
    writetable(rmse_table, fullfile(result_directory, ['rmse_rinex_' experiment '_' constellation '.csv']));
    disp(['Saved plots and RMSE table to ' result_directory]);
end

end
