function varargout = plot_cum_spec_v2(these_events, em_type, b_cal_images, maskstr)
% [S, F, T] = plot_cum_spec_v2(these_events, em_type, b_cal_images)
% Plot a "cumulative spectrogram" view of events
% Events spectrogram is the sum of the actual recorded of all events

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

%% Setup
error(nargchk(2, 4, nargin));

t_net_start = now;

% PALMER_LONGITUDE = -64.05;
% PALMER_T_OFFSET = PALMER_LONGITUDE/360;
PALMER_T_OFFSET = -(4+1/60)/24;

% Determine number of days of emission (normalizing factor)
start_datenum = floor(min([these_events.start_datenum]));
end_datenum = ceil(max([these_events.start_datenum]));
NUM_DAYS_EMISSIONS = end_datenum - start_datenum;

% Make sure we span at most one year of emissions
[start_year, ~] = datevec(start_datenum);
[end_year, ~] = datevec(end_datenum - 1/86400); % Subtract a second in case we're at midnight of the next year
if start_year ~= end_year
	error('Emissions must span only one year (start_year = %d, end_year = %d)', start_year, end_year);
end

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

if b_cal_images
	SPEC_PATH = sprintf('/home/dgolden/vlf/case_studies/chorus_%04d/synoptic_summary_plots/spec_amps', start_year);
else
	error('Uncalibrated spec_amps are not used');
end

% Use functions from the synoptic summary emission characterizer to convert
% from RGB pixel values to intensities
addpath(fullfile(danmatlabroot, 'vlf', 'synoptic_summary_emission_characterizer'));

% Don't just add emissions; add the full spectrograms
B_FULL_SPEC = false;

MASK_MIN_EMISSIONS = 10;

%% Dependent Globals
if b_cal_images
	SPEC_DB_MIN = -20;
	SPEC_DB_MAX = 25;
else
	SPEC_DB_MIN = 35;
	SPEC_DB_MAX = 80;
end

if b_cal_images
	DB_MIN = -20;
else
	DB_MIN = 0;
end

if b_use_mask
	DB_MAX = DB_MIN + 25;
else
	DB_MAX = DB_MIN + 7;
end


%% Normalization stuff for hiss / chorus with hiss
if b_use_mask
	chorus_i = cellfun(@(x) ~isempty(strfind(lower(x), 'chorus')), {these_events.emission_type});
	hiss_i = cellfun(@(x) ~isempty(strfind(lower(x), 'hiss')), {these_events.emission_type});

	chorus_only_mask = cum_spec_emission_mask(these_events, (chorus_i & ~hiss_i), f, t);
	hiss_only_mask = cum_spec_emission_mask(these_events, (~chorus_i & hiss_i), f, t);
	chorus_with_hiss_mask = cum_spec_emission_mask(these_events, (chorus_i & hiss_i), f, t);
end

%% Cycle through days and add events to the spectrogram
event_days = sort(unique(floor([these_events.start_datenum])));

for jj = 1:length(event_days)
	t_start = now;
	
	intensity_filename = sprintf('palmer_%s.mat', datestr(event_days(jj), 'yyyymmdd'));
	intensity_full_filename = fullfile(SPEC_PATH, intensity_filename);
	load(intensity_full_filename, 'spec_amp', 'f', 't');
	
	% Treat NaN (no data) values as 0 values.  A better way to do this
	% would be to count all regions with NaNs as having no data, and later
	% normalized the spec_amp by dividing by the number of regions WITH
	% data.  But that's more complicated than it's worth.
	spec_amp(isnan(spec_amp) | spec_amp < SPEC_DB_MIN) = SPEC_DB_MIN;
	spec_amp(spec_amp > SPEC_DB_MAX) = SPEC_DB_MAX;
	
	this_days_events = these_events(floor([these_events.start_datenum]) == event_days(jj));

	for kk = 1:length(this_days_events)
		event = this_days_events(kk);

		if B_FULL_SPEC
			if exist('last_date', 'var') && last_date == floor(event.start_datenum)
				continue;
			end
			last_date = floor(event.start_datenum);
		end

		start_time = fpart(event.start_datenum); % In units of days, from 0 to 1
		end_time = fpart(event.end_datenum);
		if end_time == 0, end_time = 1; end
		
		
		if ~exist('cum_spec', 'var')
			cum_spec = zeros(size(spec_amp));
			[T, F] = meshgrid(t, f);
			t_old = t;
			f_old = f;
		else
			if ~all(size(cum_spec) == size(spec_amp))
				error('spec amp %s has different dimensions than previous (%dx%d vs %dx%d)!', ...
					intensity_full_filename, size(spec_amp), size(cum_spec));
			end
			assert(all(t == t_old) && all(f == f_old));
		end
		
		if start_time > end_time % Emissions that span midnight
			em_mask_t = t >= start_time | t < end_time;
		else % All other emissions
			em_mask_t = t >= start_time & t < end_time;
		end
		em_mask_f = f >= event.f_lc & f < event.f_uc;
		
		if B_FULL_SPEC
			error('B_FULL_SPEC not implemented');
		else
			intensities = spec_amp(em_mask_f, em_mask_t) - SPEC_DB_MIN;
		end

		if b_use_mask
			switch em_type
				case 'chorus_only'
					intensities = intensities ./ chorus_only_mask;
					intensities(chorus_only_mask < MASK_MIN_EMISSIONS) = 0;
				case 'hiss_only'
					intensities = intensities ./ hiss_only_mask;
					intensities(hiss_only_mask < MASK_MIN_EMISSIONS) = 0;
				case 'chorus_with_hiss'
					intensities = intensities ./ chorus_with_hiss_mask;
					% We must have more than MASK_MIN_EMISSIONS emissions in a
					% gridpoint for that gridpoint to count
					intensities(chorus_with_hiss_mask < MASK_MIN_EMISSIONS) = 0;
				case 'chorus_or_hiss'
					intensities = intensities ./ (chorus_with_hiss_mask + chorus_only_mask + hiss_only_mask);
					intensities((chorus_with_hiss_mask + chorus_only_mask + hiss_only_mask) < MASK_MIN_EMISSIONS) = 0;
				otherwise
					error('Weird emission type: %s', event.emission_type);
			end
		end

		cum_spec(em_mask_f, em_mask_t) = cum_spec(em_mask_f, em_mask_t) + intensities;
		
		if exist('burstiness_spec', 'var')
			burstiness_spec(em_mask_f, em_mask_t) = burstiness_spec(em_mask_f, em_mask_t) + event.burstiness*intensities;
		end

		% DEBUG
%		temp = zeros(size(cum_spec));
%		temp(em_mask_f, em_mask_t) = intensities;
%		temp = intensities;
% 		imagesc(t, f, intensities);
% 		axis xy;
% 		colorbar;
% 		title(datestr(event.start_datenum));
% 		drawnow;

	end
	
	% DEBUG
% 	imagesc(t, f, cum_spec); axis xy; xlim([0.43 0.53]);
% 	title(datestr(floor(event.start_datenum)));
% 	drawnow;

	disp(sprintf('Processed %s (day %d of %d)', datestr(event_days(jj), 29), jj, length(event_days)));
end

%% Normalize by emission occurrence
% burstiness_spec is a weighted average of burstinesses, using cum_spec as
% the weights. Here, divide by the weights.
if exist('burstiness_spec', 'var')
	burstiness_spec = burstiness_spec./cum_spec;
end

if ~b_use_mask
	cum_spec = cum_spec/NUM_DAYS_EMISSIONS;
end

if b_cal_images
	cum_spec = cum_spec + SPEC_DB_MIN;
end

% Threshold burstiness spec
if exist('burstiness_spec', 'var')
	% Threshold at 1/10 of the full range
	burstiness_ampl_threshold = min(cum_spec(:)) + (max(cum_spec(:)) - min(cum_spec(:)))*0.2;
	
	burstiness_spec_thresh = burstiness_spec;
	burstiness_spec_thresh = min(max(burstiness_spec_thresh, 0), 1);
	burstiness_spec_thresh(cum_spec < burstiness_ampl_threshold) = nan;
end

% cum_spec_smooth = smooth2(cum_spec, 5, 1);
cum_spec_smooth = cum_spec;

%% Shift to get spectrogram in terms of Palmer LT
time_pivot_i = find(t >= mod(-PALMER_T_OFFSET, 1), 1, 'first');
cum_spec_smooth = [cum_spec_smooth(:, time_pivot_i:end) cum_spec_smooth(:, 1:time_pivot_i-1)];

if exist('burstiness_spec', 'var')
	burstiness_spec_thresh = [burstiness_spec_thresh(:, time_pivot_i:end) burstiness_spec_thresh(:, 1:time_pivot_i-1)];
end

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
figure
imagesc(t, f/1000, cum_spec_smooth);
s(1) = gca;
% load jet_with_white; colormap(jet_with_white);
fig = gcf;
axis xy;
datetick2('x', 'keeplimits');
ylim([0 7]);


xlabel('MLT');
ylabel('kHz');

if b_use_mask
	caxis([DB_MIN DB_MAX]);
else
% 	caxis([DB_MIN DB_MAX]);

	cax = caxis;
	if cax(2)-cax(1) >= 3
		caxis([cax(1) round(cax(1) + (cax(2) - cax(1))*0.75)]);
	end

% 	caxis([cax(1), round(cax(2) - 2)]);
end
	
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
increase_font(gcf);
figure_grow(gcf, 2, 1);

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
figure(fig);

disp(sprintf('Cumulative spectrogram for %d created in %s', start_year, time_elapsed(t_net_start, now)));
