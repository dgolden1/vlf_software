function ecg_print_emissions(start_datenum, end_datenum, emission_types, output_dir)
% Print all emissions that start between start_datenuma and end_datenum

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% Setup
if ~exist('emission_types', 'var') || isempty(emission_types)
	emission_types = {'chorus', 'hiss'};
end
if ~iscell(emission_types)
	emission_types = {emission_types};
end

if ~exist('output_dir', 'var') || isempty(output_dir)
	output_dir = uigetdir('', 'Choose image output directory');
	if ~ischar(output_dir)
		return;
	end
end

[y m d] = datevec(start_datenum);
[y2 m2 d2] = datevec(end_datenum);
assert(y == y2);
emission_filename = fullfile('/home/dgolden/vlf/case_studies/', sprintf('chorus_%04d', y), sprintf('%04d_chorus_list.mat', y));
assert(exist(emission_filename, 'file') ~= 0);

%%
load(emission_filename, 'events');

%% Parse out time range
events = events(([events.start_datenum] >= start_datenum) & ([events.start_datenum] <= end_datenum));

%% Parse out emission types
mask = false(1, length(events));
for kk = 1:length(emission_types)
	temp = strfind({events.emission_type}, emission_types{kk});
	mask = mask | cellfun(@(x) ~isempty(x), temp);
end

events = events(mask);

%% Print them
bPNG = true;
bEPS = true;

for kk = 1:length(events)
	ecg_print_emission(events(kk), output_dir, bPNG, bEPS)
end
