function plot_palmer_chorus_hiss_cum_specs(events)
% Plot radial cumulative spectrograms of chorus and hiss at Palmer

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

%% Setup
% load /home/dgolden/vlf/case_studies/chorus_hiss_detection/databases/auto_chorus_hiss_db_em_char_all_reprocessed.mat
close all;

output_dir = '~/temp';

addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics')); % For plot_cum_spec_v4.m, data_gaps.mat

%% Get data gaps
dg = load('data_gaps.mat');
synoptic_epochs = dg.synoptic_epochs(dg.b_data);

%% Make plots
plot_one_cum_spec(events, 'chorus', synoptic_epochs, output_dir);
plot_one_cum_spec(events, 'hiss', synoptic_epochs, output_dir);


function plot_one_cum_spec(events, em_type, synoptic_epochs, output_dir)

%% Parse out this emission type
events = events(strcmp({events.type}, em_type));

%% Plot
% switch em_type
%   case 'chorus'
%     f = linspace(400, 6e3, 64);
%     freq_lines = (2:2:4)*1e3;
%   case 'hiss'
%     f = linspace(400, 3e3, 64);
%     freq_lines = (1:2)*1e3;
% end
f = logspace(log10(300), log10(50e3), 100);
freq_lines = [300, 1e3, 3e3, 1e4, 3e4];
df = diff(f(1:2));

these_events = events;
ec = [these_events.ec];

% Amplitudes are in dB-fT; change to dB-fT/Hz^(1/2) by dividing by
% bandwidth
ampl = 10*log10(10.^([ec.ampl_true]/10)./([these_events.f_uc] - [these_events.f_lc]));

% Convert to fT^2/Hz
% ampl = ampl/10;

min_img_val = -20;

ampl_mtx = repmat(ampl, length(f), 1);
f_mtx = repmat(f(:), 1, length(ampl));
ampl_mtx(f_mtx < repmat([these_events.f_lc], length(f), 1) | f_mtx > repmat([these_events.f_uc], length(f), 1)) = min_img_val;

plot_cum_spec_v4(fpart([these_events.start_datenum]), log10(f), ampl_mtx, ...
  'norm_datenums', fpart(synoptic_epochs), ...
  'mlt_offset', -4, 'min_img_val', min_img_val, 'b_radial', true);

cax = [-20 -18];
caxis(cax);
axis equal
% axis([-1 1 -1 1]*1.05);

colorbar off;
xlabel('');
set(gca, 'xticklabel', []);
ylabel('');
set(gca, 'yticklabel', []);

%   title(sprintf('%s', datestr([2001 kk 1 0 0 0], 'mmm')));
title('');

increase_font;

plot_f_lines(f);

c = colorbar;
ylabel(c, 'avg log_{10}fT^2/Hz');
ylabel(c, 'avg dB-fT/Hz^{1/2}');

% output_filename = fullfile(output_dir, sprintf('raw_palmer_cum_spec_%s.png', em_type));
% 
% % -density and -resample flags decimate image size by a factor of 4,
% % effectively performing antialiasing
% print('-dpng', '-r300', output_filename);
% unix(sprintf('mogrify -trim -density 2 -resample 1 %s', output_filename));
% fprintf('Wrote %s\n', output_filename);

% paper_print('raw_palmer_seasonal_hiss', 16, 1, '/home/dgolden/vlf/papers/dgolden/2011_stat_hiss_pred/images')

%% Make a figure with the colorbar
% cax = caxis;
% figure;
% caxis(cax);
% axis off;
% c = colorbar('location', 'west');
% ylabel(c, 'avg log_{10}fT^2/Hz');
% paper_print('raw_palmer_cum_spec_colorbar', 6, 2, output_dir)

1;
