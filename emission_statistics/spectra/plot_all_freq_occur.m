function [freq, occur_rate] = plot_all_freq_occur
% get_freq_occur
% 
% Plot the occurrence rate for emissions by frequency

% By Daniel Golden (dgolden1 at stanford dot edu), October 2008
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics'));

%% Load events
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');

[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events);

chorus_events = remove_outside_em_int(chorus_events, 'chorus_only');
hiss_events = remove_outside_em_int(hiss_events, 'hiss_only');
chorus_with_hiss_events = remove_outside_em_int(chorus_with_hiss_events, 'chorus_with_hiss');

[freq_edge_centers, occur_rate_hiss_only] = emstat_hist_freq_occur('hiss_only', hiss_events);
[freq_edge_centers, occur_rate_chorus_only] = emstat_hist_freq_occur('chorus_only', chorus_events);
[freq_edge_centers, occur_rate_chorus_with_hiss] = emstat_hist_freq_occur('chorus_with_hiss', chorus_with_hiss_events);

%% Plot
ssr = 3;

figure;
hold on;
% lhiss = plot(freq_edge_centers, occur_rate_hiss_only, 'g', 'LineWidth', 3);
lhiss = plot(freq_edge_centers, occur_rate_hiss_only, 'k', 'LineWidth', 3);
plot(freq_edge_centers(1:ssr:end), occur_rate_hiss_only(1:ssr:end), 'ks', 'MarkerFaceColor', 'w', 'MarkerSize', 7);

% lchorus = plot(freq_edge_centers, occur_rate_chorus_only, 'b', 'LineWidth', 3);
lchorus = plot(freq_edge_centers, occur_rate_chorus_only, 'k', 'LineWidth', 3);
plot(freq_edge_centers(1:ssr:end), occur_rate_chorus_only(1:ssr:end), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 7);

% lchorushiss = plot(freq_edge_centers, occur_rate_chorus_with_hiss, 'r', 'LineWidth', 3);
lchorushiss = plot(freq_edge_centers, occur_rate_chorus_with_hiss, 'k', 'LineWidth', 3);
plot(freq_edge_centers(1:ssr:end), occur_rate_chorus_with_hiss(1:ssr:end), 'kd', 'MarkerFaceColor', 'w', 'MarkerSize', 8);
grid on;

xlabel('Frequency (kHz)');
ylabel('Occurrence probability (per emission)');

legend([lhiss lchorus lchorushiss], 'Hiss only', 'Chorus only', 'Chorus with hiss');
increase_font(gcf, 16);
