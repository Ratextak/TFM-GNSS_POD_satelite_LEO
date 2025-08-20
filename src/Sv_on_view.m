function Sv_on_view(experiment, input_files, result_directory, events, SAVE_PLOT, constellation)
% -----------------------------------------------------------
%  Function Name:   Sv_on_view
%  Description:     Processes GNSS data from RINEX files and plots
%  Satellites on View
%  Inputs:
%     experiment (string)
%     input_files (string, cell array, or struct)
%     result_directory (string)
%     events (struct array with fields Time, Label)
%     SAVE_PLOT (boolean)
%     constellation (string, optional: 'GPS' or 'Galileo')
% -----------------------------------------------------------

    if nargin < 6
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
    
    % ---------------- Extract data ----------------
    t   = data2.Time;         % datetime array
    prn = data2.SatelliteID;  % numeric PRN
    
      % ---------------- Plot ----------------
    figure('Name',['SV on view - ' constellation],'Visible','on');
    hold on;
    
    plot(t, prn, 'k.', 'MarkerSize', 6); % black dots timeline
    
    % Events
    for i = 1:length(events)
        xline(events(i).Time, '--r', events(i).Label, 'LabelOrientation','horizontal');
    end
    
    xlabel('Time');
    ylabel('PRN');
    title(['Satellites on View - ' constellation]);
    grid on;
    hold off;
    
    % ---- Save plot if requested ----
    if SAVE_PLOT
        if ~exist(result_directory, 'dir')
            mkdir(result_directory);
        end
        filename = fullfile(result_directory, [experiment '_SV_view_' constellation '.png']);
        saveas(gcf, filename);
        disp(['SV on view: ' experiment ' plot saved to ' filename]);
    end
end
