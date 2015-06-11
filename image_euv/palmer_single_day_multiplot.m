function palmer_single_day_multiplot(day_datenum)
% palmer_single_day_multiplot(day_datenum)
% Function to plot...
% a) 24-hour spectrogram (including emission tags)
% b) Kp
% c) DST
% d) Palmer plasmapause location
%    ... all on a single figure
% 
% Relies on "vlftool_24_hour_fcn", "image_euv", and other software packages

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$



%% Setup
addpath('/home/dgolden/vlf/vlf_software/dgolden/synoptic_summary_emission_characterizer');
addpath('/home/dgolden/vlf/vlf_software/dgolden/image_euv');
[y m d hh mm ss] = datevec(day_datenum);

SPEC_PATH = sprintf('/home/dgolden/vlf/case_studies/chorus_%04d/synoptic_summary_plots/spec_amps', y);
KP_PATH = '/home/dgolden/vlf/case_studies/kp';
PP_DB_PATH = '/home/dgolden/vlf/case_studies/image_euv_2001';
EMISSION_DB_PATH = sprintf('/home/dgolden/vlf/case_studies/chorus_%04d', y);

figure;

%% The 24-hour spectrogram
% Load image intensity file (run
% /home/dgolden/vlf/vlf_software/dgolden/emission_statistics/get_amp_from_spec.m 
% to make image intensity files)
fname_spec = fullfile(SPEC_PATH, sprintf('palmer_%04d%02d%02d.mat', y, m, d));
load(fname_spec, 'spec_amp');

% time = linspace(datenum([0 0 0 0 5 0]), datenum([0 0 0 23 50 0]), size(spec_amp, 2));
time = linspace(datenum([0 0 0 0 0 0]), datenum([0 0 0 23 59 0]), size(spec_amp, 2));
freq = linspace(0.3, 10, size(spec_amp, 1));

h_img_ax = subplot(4, 1, 1:2);
imagesc(time, freq, flipud(spec_amp)); axis xy;
% colorbar;
xlim([0 1]);
datetick('x', 'KeepLimits');
xlabel('Time (UTC)');
ylabel('Frequency (kHz)');
title(datestr(day_datenum, 'yyyy-mm-dd'));

% Mark emissions
emission_db_filename = fullfile(EMISSION_DB_PATH, sprintf('%04d_chorus_list.mat', y));
ecg_mark_known_emissions(emission_db_filename, day_datenum, h_img_ax, false, 'true_time');

%% The Kp Plot
% h_kp_ax = subplot(4, 1, 3);
% kp_filename = fullfile(KP_PATH, sprintf('kp%04d.txt', y));
% kp_plot(day_datenum, day_datenum+1, kp_filename, h_kp_ax);

%% Or... the DST plot
h_dst_ax = subplot(4, 1, 4);
y_min = -100;
y_max = 20;
ylim([y_min y_max]);

% Shade the before and after days
hold on;
fill([day_datenum-1 day_datenum day_datenum day_datenum-1], [y_min y_min y_max y_max], 0.9*[1 1 1], 'EdgeColor', 'none');
fill([day_datenum+1 day_datenum+2 day_datenum+2 day_datenum+1], [y_min y_min y_max y_max], 0.9*[1 1 1], 'EdgeColor', 'none');

dst_plot(day_datenum-1, day_datenum+2, [], h_dst_ax);
datetick('x', 6, 'KeepLimits');


%% The IMAGE EUV plasmapause plot
h_pp_ax = subplot(4, 1, 3);
pp_db_filename = fullfile(PP_DB_PATH, 'palmer_pp_db.mat');
plot_palmer_pp_db(day_datenum, day_datenum+1, pp_db_filename, h_pp_ax)
title('');
