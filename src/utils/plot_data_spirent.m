%% -----------------------------------------------------------
%  Script Name:   plot_data.m
%  Description:   plot GNSS data from SPIRENT log in CSV.
%  Author:        gomezlma@inta.es
%  Date:          [2025-09-03]
%  Inputs:        CSV file from SPIRENT simulation.
%  Outputs:       plots of GNSS data.
%  Dependencies:  Requires MATLAB R2020b or later.
%  -----------------------------------------------------------
close all

results_directory=[ '../figures/' 'plot_results_' experiment '\'];

%%
figure
geoplot(v1_lat,v1_lon,"-.")
geobasemap streets
title('Spirent GT Trayectory during test');

if SAVE_PLOT
    saveas(gcf, [results_directory 'trayectory.png'])
end
%% Create the plots velocity and acceleration

figure;
% Plot velocity
subplot(2,1,1); % Split the window into 2 rows and 1 column
plot(time, [v1_vel.v1x_vel v1_vel.v1y_vel v1_vel.v1z_vel], '-o', 'LineWidth', 2, 'MarkerSize', 5);
title('Spirent GT Velocity vs. Time');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
grid on;

% Plot acceleration
subplot(2,1,2); % Second subplot
plot(time, [v1_acc_jrk.v1x_acc v1_acc_jrk.v1y_acc v1_acc_jrk.v1z_acc], '-x', 'LineWidth', 2, 'MarkerSize', 5);
title('Spirent GT Acceleration vs. Time');
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;

if SAVE_PLOT
    saveas(gcf, [results_directory 'vel_acc.png'])
end
%% Plot the satellite sv level (UA) over time

figure;
plot(time,(cell2mat(struct2cell(sig_level)')))
grid minor
xlabel('Time (s)');
ylabel('sv level (UA)');
title('Spirent GT SV signal level over time')

if SAVE_PLOT
    saveas(gcf, [results_directory 'sv_level.png'])
end
%% Plot the satellite sv elev (deg) over time

figure;
plot(time,rad2deg(cell2mat(struct2cell(sig_elev)')))
xlabel('Time (s)');
ylabel('sv elev (deg)');grid minor
title('Spirent GT SV elevation over time')

if SAVE_PLOT
    saveas(gcf, [results_directory 'sv_elev.png'])
end
%% Plot the satellite sv azim (deg) over time

figure;
plot(time,rad2deg(cell2mat(struct2cell(sig_azim)')))
xlabel('Time (s)');
ylabel('sv azim (deg)');grid minor
title('Spirent GT SV azimut over time')

if SAVE_PLOT
    saveas(gcf, [results_directory 'sv_azim.png'])
end
%% Plot the satellite p-ranges over time

figure;
hold on;  % Hold on to plot all p-ranges on the same figure

% Loop through the fields in the 'p-ranges' structure
fields = fieldnames(pranges);
for i = 1:length(fields)
    % Plot all data points for the current field (satellite p-ranges data)
    plot(time, pranges.(fields{i}), 'DisplayName', fields{i});
end

% Label the plot
xlabel('Time (s)');
ylabel('Satellite P-Range (m)');
title('Spirent GT Satellite P-Ranges Over Time');
grid minor;

% Add a legend to distinguish between different satellites/signals
% legend('show','Location','eastoutside');
if SAVE_PLOT
    saveas(gcf, [results_directory 'p-ranges.png'])
end
%%
% Plot the satellite doppler_shift over time
figure;
hold on;  % Hold on to plot all doppler_shift on the same figure

% Loop through the fields in the 'doppler_shift' structure
fields = fieldnames(doppler_shift);
for i = 1:length(fields)
    % Plot all data points for the current field (satellite doppler_shift data)
    plot(time, doppler_shift.(fields{i}), 'DisplayName', fields{i});
end

% Label the plot
xlabel('Time (s)');
ylabel('Satellite doppler shift (Hz)');
title('Spirent GT Satellite doppler shift Over Time');
grid minor;

% Add a legend to distinguish between different satellites/signals
% legend('show','Location','eastoutside');
if SAVE_PLOT
    saveas(gcf, [results_directory 'doppler_shift.png'])
end
%%
if CLOSE_at_END
    close all
end