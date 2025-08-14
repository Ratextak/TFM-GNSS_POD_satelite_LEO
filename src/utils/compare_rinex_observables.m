function compare_rinex_observables(experiment, rinex1, rinex2, result_directory, satelliteIDs, SAVE_PLOT, constellation)
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

if nargin < 7
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

%% ---------------- Initialize RMSE and error arrays ----------------
rmse_table = table('Size', [length(satelliteIDs), 4], ...
                   'VariableTypes', {'double','double','double','double'}, ...
                   'VariableNames', {'SV','RMSE_S1C','RMSE_D1C_Hz','RMSE_C1C_m'});

all_err_s1c = [];
all_err_d1c = [];
all_err_c1c = [];

%% ---------------- Create figure for time series ----------------
f1 = figure('Name','Observable Errors','WindowState','maximized');

for idx = 1:length(satelliteIDs)
    sv = satelliteIDs(idx);
    d1 = data1(data1.SatelliteID == sv, :);
    d2 = data2(data2.SatelliteID == sv, :);

    [t_common, ia, ib] = intersect(d1.Time, d2.Time);

    % ---------------- Detect available observables ----------------
    available_obs = intersect(fieldnames(d1), fieldnames(d2));

    cn0_field        = available_obs(contains(available_obs,'S')); % C/N0
    doppler_field    = available_obs(contains(available_obs,'D')); % Doppler
    pseudorange_field= available_obs(contains(available_obs,'C')); % Pseudorange

    % ---------------- Calculate errors if fields exist ----------------
    if ~isempty(cn0_field)
        err_cn0 = d1.(cn0_field{1})(ia) - d2.(cn0_field{1})(ib);
    else
        err_cn0 = [];
    end

    if ~isempty(doppler_field)
        err_doppler = d1.(doppler_field{1})(ia) - d2.(doppler_field{1})(ib);
    else
        err_doppler = [];
    end

    if ~isempty(pseudorange_field)
        err_pseudorange = d1.(pseudorange_field{1})(ia) - d2.(pseudorange_field{1})(ib);
    else
        err_pseudorange = [];
    end

    % ---------------- Accumulate errors ----------------
    all_err_s1c = [all_err_s1c; err_cn0];
    all_err_d1c = [all_err_d1c; err_doppler];
    all_err_c1c = [all_err_c1c; err_pseudorange];

    % ---------------- Calculate RMSE ----------------
    rmse_table.SV(idx) = sv;
    rmse_table.RMSE_S1C(idx) = sqrt(mean(err_cn0.^2,'omitnan'));
    rmse_table.RMSE_D1C_Hz(idx) = sqrt(mean(err_doppler.^2,'omitnan'));
    rmse_table.RMSE_C1C_m(idx) = sqrt(mean(err_pseudorange.^2,'omitnan'));

    % ---------------- Plot time series ----------------
    subplot(3,1,1); hold on; plot(t_common, err_cn0, '.-', 'DisplayName', ['SV ' num2str(sv)]);
    subplot(3,1,2); hold on; plot(t_common, err_doppler, '.-', 'DisplayName', ['SV ' num2str(sv)]);
    subplot(3,1,3); hold on; plot(t_common, err_pseudorange, '.-', 'DisplayName', ['SV ' num2str(sv)]);
end

%% ---------------- Finalize time series plots ----------------
subplot(3,1,1); ylabel('\Delta C/N0 (dB-Hz)'); title('Error in C/N0'); grid minor; legend('Location','eastoutside');
subplot(3,1,2); ylabel('\Delta Doppler (Hz)'); title('Error in Doppler'); grid minor;
subplot(3,1,3); ylabel('\Delta Pseudorange (m)'); xlabel('Time'); title('Error in Pseudorange'); grid minor;
sgtitle(['Observable Errors: ' experiment ' - ' constellation]);

if SAVE_PLOT
    if ~exist(result_directory, 'dir'), mkdir(result_directory); end
    saveas(f1, fullfile(result_directory, ['errors_rinex_' experiment '_' constellation '.png']));
end

%% ---------------- Histogram plots ----------------
f2 = figure('Name','Error Histograms','WindowState','maximized');

subplot(3,1,1); histogram(all_err_s1c,'Normalization','probability'); grid on;
xlabel('\Delta C/N0 (dB-Hz)'); ylabel('Probability'); title('Histogram of C/N0 Error');

subplot(3,1,2); histogram(all_err_d1c,'Normalization','probability'); grid on;
xlabel('\Delta Doppler (Hz)'); ylabel('Probability'); title('Histogram of Doppler Error');

subplot(3,1,3); histogram(all_err_c1c,'Normalization','probability'); grid on;
xlabel('\Delta Pseudorange (m)'); ylabel('Probability'); title('Histogram of Pseudorange Error');

sgtitle(['Error Histograms: ' experiment ' - ' constellation]);

%% ---------------- Save histogram and RMSE ----------------
if SAVE_PLOT
    saveas(f2, fullfile(result_directory, ['histogram_rinex_' experiment '_' constellation '.png']));
    writetable(rmse_table, fullfile(result_directory, ['rmse_rinex_' experiment '_' constellation '.csv']));
    disp(['Saved plots and RMSE table to ' result_directory]);
end

end
