function varargout = plot_cum_spec_v3(em_type, these_events, synoptic_epochs, b_cal_images, maskstr, ax)
% [S, F, T] = plot_cum_spec_v3(em_type, these_events, synoptic_epochs, b_cal_images, maskstr)
% Plot a "cumulative spectrogram" view of events
% Events spectrogram is the sum of the actual recorded of all events
% 
% Revised from plot_cum_spec_v2 in order to accomodate emissions determined
% via neural network

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
error(nargchk(2, 6, nargin));

t_net_start = now;

PALMER_T_OFFSET = -(4+1/60)/24;

start_datenum = floor(min([these_events.start_datenum]));
end_datenum = ceil(max([these_events.start_datenum]));

if ~exist('b_cal_images', 'var') || isempty(b_cal_images)
	b_cal_images = true;
end
if ~exist('maskstr', 'var') || isempty(maskstr) || ~strcmp(maskstr, 'mask')
	b_use_mask = false;
else
	% Use normalizing mask, so emission intensity is the true average (for a
	% given time/freq), instead of the average over all spectrograms containing
	% this type of emission
	b_use_mask = true;
end

MASK_MIN_EMISSIONS = 10;

%% Dependent Globals
AMPL_UNIT = 'dB-fT/Hz^{1/2}';

DB_MIN = -20; % dB-fT/Hz^{1/2}

%% Cycle through events and add them to the spectrogram
f = linspace(0, 10e3, 64);
t = (0:95)/96; % Fractions of a day
cum_spec = zeros(length(f), 96);
count = zeros(size(cum_spec)); % Number of events in each bin (for normalization)

for jj = 1:length(these_events)
	this_event = these_events(jj);
  
  f_idx = f >= this_event.ec.f_lc & f <= this_event.ec.f_uc;
  t_idx = nearest(fpart(this_event.start_datenum), t);
  
  cum_spec(f_idx, t_idx) = cum_spec(f_idx, t_idx) + (this_event.ec.ampl_avg_medio - DB_MIN);
  count(f_idx, t_idx) = count(f_idx, t_idx) + 1;

		% DEBUG
%		temp = zeros(size(cum_spec));
%		temp(em_mask_f, em_mask_t) = intensities;
%		temp = intensities;
% 		imagesc(t, f, intensities);
% 		axis xy;
% 		colorbar;
% 		title(datestr(event.start_datenum));
% 		drawnow;

	% DEBUG
% 	imagesc(t, f, cum_spec); axis xy; xlim([0.43 0.53]);
% 	title(datestr(floor(event.start_datenum)));
% 	drawnow;
end

%% Normalize by emission occurrence
if b_use_mask
  count(count == 0) = 1;
  cum_spec(count < MASK_MIN_EMISSIONS) = 0;
  cum_spec = cum_spec./count + DB_MIN;
else
  n_total = hist(fpart(synoptic_epochs), 5/1440:1/96:1);
  cum_spec = cum_spec./repmat(n_total, length(f), 1) + DB_MIN;
end

% cum_spec_smooth = smooth2(cum_spec, 5, 1);
cum_spec_smooth = cum_spec;

%% Shift to get spectrogram in terms of Palmer LT
time_pivot_i = find(t >= mod(-PALMER_T_OFFSET, 1), 1, 'first');
cum_spec_smooth = [cum_spec_smooth(:, time_pivot_i:end) cum_spec_smooth(:, 1:time_pivot_i-1)];

%% Save output arguments
if nargout > 0
	varargout{1} = cum_spec_smooth;
end
if nargout > 1
	varargout{2} = f;
end
if nargout > 2
	varargout{3} = t;
end

if nargout > 0
	return;
end

%% Plot spectrogram
if exist('ax', 'var') && ~isempty(ax)
  saxes(ax);
else
  figure
end

imagesc(t, f/1000, cum_spec_smooth);
s(1) = gca;
% load jet_with_white; colormap(jet_with_white);
fig = gcf;
axis xy;
datetick('x', 'keeplimits');
ylim([0.56 7]);


xlabel('MLT');
ylabel('kHz');

% if b_use_mask
% 	caxis([DB_MIN DB_MAX]);
% else
% % 	caxis([DB_MIN DB_MAX]);
% 
% 	cax = caxis;
% 	if cax(2)-cax(1) >= 3
% 		caxis([cax(1) round(cax(1) + (cax(2) - cax(1))*0.75)]);
% 	end
% 
% % 	caxis([cax(1), round(cax(2) - 2)]);
% end
	
c = colorbar;
if b_cal_images
	set(get(c, 'ylabel'), 'string', 'avg dB-fT/Hz^{1/2}');
else
	set(get(c, 'ylabel'), 'string', 'avg uncal dB (wrt noise floor)');
end

title(sprintf('Cumulative spectrogram, %d %s emissions, %s to %s', length(these_events), ...
	em_type, datestr(start_datenum, 29), datestr(end_datenum, 29)));

set(gca, 'tickdir', 'out');
grid on;

if ~exist('ax', 'var') || isempty(ax)
  increase_font(gcf);
  figure_grow(gcf, 2, 1);
end

set(gcf, 'tag', 'cum_spec_amplitude');

% title(sprintf('VLF emission events (%s) 2003', strrep(em_type, '_', '\_')));

%% Add L shell 1/2 fHeq lines
% add_fh_lines_to_spec(gca);

%% Make a figure of the colorbar
% figure;
% j = jet_with_white;
% image(1, linspace(DB_MIN, DB_MAX, size(j, 1)), permute(j, [1 3 2]));
% axis xy;
% set(gca, 'xticklabel', {}, 'YAxisLocation', 'right');
% if b_cal_images
% 	ylabel('average dB wrt 10^{-29} T^2 Hz^{-1}');
% else
% 	ylabel('average uncal dB (wrt noise floor)');
% end
% figure_squish(gcf, 6, 1);
% increase_font(gcf, 16);

%% Make burstiness figure
% figure;
% imagesc(t, f, burstiness_spec_thresh);
% s(2) = gca;
% axis xy;
% datetick2('x', 'keeplimits');
% set(gca, 'tickdir', 'out');
% grid on;
% ylim([0 7000]);
% 
% % Make the nan values a different color
% colormap([0.9*[1 1 1]; jet(64)]);
% caxis([-1/64 1]/2);
% 
% xlabel('Hour (Palmer LT)');
% ylabel('Frequency (Hz)');
% 
% c = colorbar;
% ylabel(c, 'Weighted burstiness');
% 
% title(sprintf('Thresholded burstiness, %d %s emissions, %s to %s', length(these_events), ...
% 	em_type, datestr(start_datenum, 29), datestr(end_datenum, 29)));
% 
% increase_font(gcf);
% figure_grow(gcf, 2, 1);
% 
% set(gcf, 'tag', 'cum_spec_burstiness');
% linkaxes(s);

%% Finish up

disp(sprintf('Cumulative spectrogram created in %s', time_elapsed(t_net_start, now)));
