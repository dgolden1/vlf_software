function marker_handles = ecg_mark_known_emissions(db_filename, start_datenum, end_datenum, h_ax, bIncludeCaption, time_style, single_em)
% marker_handles = ecg_mark_known_emissions(db_filename, start_datenum, end_datenum, h_ax, bIncludeCaption, time_style, single_em)
% Mark known emissions on the current spectrogram

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Setup

if ~exist('bIncludeCaption', 'var') || isempty(bIncludeCaption), bIncludeCaption = true; end
if ~exist('time_style', 'var') || isempty(time_style), time_style = 'true_time'; end
if ~exist('single_em', 'var'), single_em = []; end

if ~exist('end_datenum', 'var') || isempty(end_datenum)
	end_datenum = start_datenum + 1;
end

%%
set(h_ax, 'NextPlot', 'add'); % Turn hold on

if ~isempty(single_em)
	this_days_emissions = single_em;
else
	load(db_filename);
	emission_start_datenums = [events.start_datenum];

	this_days_emissions = events(emission_start_datenums >= start_datenum & ...
		emission_start_datenums < end_datenum);

	if isempty(this_days_emissions)
		disp(sprintf('No recorded emissions on %s', datestr(start_datenum, 'mmm dd, yyyy')));
		return;
	end
end

if bIncludeCaption
	marker_handles = repmat(struct('r', nan, 't', nan), length(this_days_emissions), 1);
else
	marker_handles = repmat(struct('r', nan, 't', []), length(this_days_emissions), 1);
end

marker_handles = struct('r', {}, 't', {});
for kk = 1:length(this_days_emissions)
	marker_handle = ecg_add_single_emission_marker(this_days_emissions(kk), h_ax, bIncludeCaption, [], time_style, marker_handles);
	marker_handles(kk) = marker_handle;
end
