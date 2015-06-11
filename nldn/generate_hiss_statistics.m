function generate_hiss_statistics
% generate_hiss_statistics
% Comb through all the hiss occurrences from 2003. Save a vector with
% 1-hour bins through the course of the year. Each bin has the ampltiude of
% hiss that occurred within that hour; the amplitude is 0 for no hiss.

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
chorus_list_dir = '/home/dgolden/vlf/case_studies/chorus_2003';
spec_amp_dir = '/home/dgolden/vlf/case_studies/chorus_2003/synoptic_summary_plots/spec_amps';
% spec_amp_dir = '/home/dgolden/temp/spec_amps';
output_dir = '/home/dgolden/vlf/case_studies/nldn/statistics';

date_start = datenum([2003 01 01 0 0 0]);
date_end = datenum([2003 11 1 0 0 0]);
hour = (date_start:1/24:date_end).';
hiss_amp = ones(size(hour)) * -20;

%% Load events
addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics'));
load(fullfile(chorus_list_dir, '2003_chorus_list.mat'), 'events');
[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events);


%% Loop over emissions
last_spec_amp_filename = '';
last_spec_amp = [];
for kk = 1:length(hiss_events)
	this_spec_amp_filename = sprintf('palmer_%s.mat', datestr(hiss_events(kk).start_datenum, 'yyyymmdd'));
	
	% If we have to load a new spec_amp...
	if ~strcmp(this_spec_amp_filename, last_spec_amp_filename)
		if ~exist(fullfile(spec_amp_dir, this_spec_amp_filename), 'file')
			error('Missing spec amp file %s', this_spec_amp_filename);
		end
		load(fullfile(spec_amp_dir, this_spec_amp_filename), 'spec_amp', 'f', 't');
		disp(sprintf('Loaded %s', this_spec_amp_filename));
		last_spec_amp_filename = this_spec_amp_filename;
		last_spec_amp = spec_amp;
		
% 		sfigure(1); clf; imagesc(t, f, spec_amp); axis xy; datetick('x', 'keeplimits');
	end
		
	% What hours does this emission span?
	hour_idx = find(hiss_events(kk).start_datenum < hour(2:end) & hiss_events(kk).end_datenum > hour(1:end-1));

	% For each of those hours, find the mean emission amplitude in that
	% hour within the emission's frequency range
	f_i = find(f >= hiss_events(kk).f_lc*1e3 & f <= hiss_events(kk).f_uc*1e3);
	for jj = 1:length(hour_idx)
		t_lower = max(fpart(hiss_events(kk).start_datenum), fpart(hour(hour_idx(jj))));
		t_upper = min(fpart(hiss_events(kk).end_datenum), fpart(hour(hour_idx(jj) + 1)));
		
		% If the emission ends at midnight, its end time will be 0
		if t_upper < t_lower
			assert(t_upper == 0)
			t_upper = 1;
		end
% 		t_lower = fpart(hour(hour_idx(jj)));
% 		t_upper = fpart(hour(hour_idx(jj) + 1));
		t_i = find(t >= t_lower & t <= t_upper);
		
		emission_chunk = spec_amp(f_i, t_i);
% 		sfigure(2); clf; imagesc(t(t_i), f(f_i), emission_chunk); axis xy; colorbar; datetick('x', 'keeplimits'); title('Precleaned');
		% Eliminate sferics by looking for outliers when summing down
		% columns
		sferic_mask = true(size(t_i));
		spec_amp_col_sum = sum(emission_chunk);
		sferic_mask(spec_amp_col_sum > mean(spec_amp_col_sum) + std(spec_amp_col_sum)) = false;
		t_i(~sferic_mask) = [];
		emission_chunk_cleaned = emission_chunk(:, sferic_mask);
		
		% There could be more than one hiss emission in one hour; choose
		% the one with greater amplitude
		this_hiss_amp = mean(flatten(emission_chunk_cleaned));
		hiss_amp(hour_idx(jj)) = max(hiss_amp(hour_idx(jj)), this_hiss_amp);
% 		sfigure(2); clf; imagesc(t(t_i), f(f_i), emission_chunk_cleaned); axis xy; colorbar; datetick('x', 'keeplimits'); title('Cleaned');
	end
end

%% Save
save(fullfile(output_dir, 'hiss_statistics.mat'), 'hour', 'hiss_amp');

figure
plot(hour, hiss_amp, 'LineWidth', 2);
grid on;
xlim([date_start date_end]);
datetick('x', 'keeplimits');
xlabel('Date');
ylabel('Hiss amplitude (dB-fT/Hz^{-1/2})');

disp('');
