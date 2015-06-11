function create_event_catalog(start_datenum, end_datenum)
% Create a catalog of all known emissions

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
if ~exist('start_datenum', 'var') || isempty(start_datenum)
	start_datenum = 0;
end
if ~exist('end_datenum', 'var') || isempty(end_datenum)
	end_datenum = Inf;
end

%% Set paths
[~, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
	case 'quadcoredan.stanford.edu'
		output_dir = '~/temp/event_catalog';
		db_filename = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_db_2001.mat';
		% db_filename = '2003_chorus_list.mat';
	case 'vlf-alexandria'
		output_dir = '/array/data_products/dgolden/output/event_catalog';
		db_filename = '/array/data_products/dgolden/input/auto_chorus_hiss_db_2001.mat';
	case 'scott.stanford.edu'
		output_dir = '/data/user_data/dgolden/output/event_catalog';
		db_filename = '/data/user_data/dgolden/input/auto_chorus_hiss_db_2001.mat';
end

%% Load and parse events
load(db_filename, 'events');
[~, ix] = sort([events.start_datenum]);
events = events(ix);

events = events(([events.start_datenum] >= start_datenum) & ([events.end_datenum] <= end_datenum));

%% Additional criteria on events
% % Delete events that occur on the same day as another event for simplicity.
% [b, m, n] = unique(round_to_syn_min([events.start_datenum]))
% A = accumarray(n(:), ones(size(n(:))));
% m(A > 1) = [];
% events = events(m);

% events = events([events.burstiness] >= 0.3);

start_datenums = [events.start_datenum];

% Sometimes there is more than one event at the same time; don't it more
% than once
% [start_datenums, m] = unique(round_to_syn_min([events.start_datenum]));

%% Plot and print
sec_per_snapshot = 10;
f_lc = 0;
f_uc = 8e3;
t_net_start = now;
for kk = 1:length(events)
	t_start = now;
	try
		output_filename = zoom_single_file(events(kk), db_filename, f_lc, f_uc, sec_per_snapshot, output_dir);
		fprintf('Wrote %s (event %d of %d) in %s\n', output_filename, kk, length(start_datenums), time_elapsed(t_start, now));
	catch er
		if strcmp(er.identifier, 'prune:noFilesLeft')
			disp(sprintf('Warning: no match found for emission %s\n', datestr(start_datenums(kk))));
			continue;
		else
			rethrow(er);
		end
	end
end
t_net_end = now;
disp(sprintf('Finished in %s', time_elapsed(t_net_start, t_net_end)));

function output_filename = zoom_single_file(event, db_filename, f_lc, f_uc, sec_per_snapshot, output_dir)

% Avoid emissions that span midnight; chop them at midnight
if fpart(event.end_datenum) < fpart(event.start_datenum)
	event.end_datenum = ceil(event.start_datenum);
end

start_datenum = event.start_datenum;
end_datenum = event.end_datenum;

ecg_zoom_emission([], start_datenum, end_datenum, db_filename, f_lc, f_uc, sec_per_snapshot, [], event, 'cleaned');
% ecg_zoom_emission([], event(kk).start_datenum, event(kk).end_datenum, db_filename, [], [], [], 170); % Get the last 5 seconds of data

% Sort things by start hour, rounded to the nearest whole hour
% full_output_dir = fullfile(output_dir, datestr(floor(start_datenum*24)/24, 'HHMM'));
% if ~exist(full_output_dir, 'dir')
% 	mkdir(full_output_dir);
% end
full_output_dir = output_dir;

output_filename = fullfile(full_output_dir, sprintf('B%03.0f_PA%s.png', max(0, event.burstiness)*100, datestr(start_datenum, 'yyyy_mm_ddTHHMM')));

% Some bug in creating the spectrogram confuses points and inches at some point;
% this kudge fixes it
if strcmp(get(gcf, 'paperunits'), 'points')
	error('paperunits == points???');
end
drawnow;
print('-dpng', '-r75', output_filename);
% print('-dpng', output_filename);


function output_datenum = round_to_syn_min(input_datenum)
% Round input_datenum to the nearest synoptic minute (5, 20, 35, 50)

output_datenum = round((input_datenum - 5/1440)*96)/96 + 5/1440;
