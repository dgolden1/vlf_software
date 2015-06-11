function events = combine_cross_day_events(events)
% events = combine_cross_day_events(events)
% Function to take events that span multiple days (e.g., an event that ends
% at midnight followed by one that starts at midnight) and combine them

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2007
% $Id$

%% Setup
error(nargchk(1, 1, nargin));

% Sort events
events = ecg_sort_events(events);

% Find events that end at midnight
end_midnight = (round(([events.end_datenum] - floor([events.end_datenum]))*1440) >= 1435) | ...
	(round(([events.end_datenum] - floor([events.end_datenum]))*1440) == 0);

% Find events that start at midnight
start_midnight = (round(([events.start_datenum] - floor([events.start_datenum]))*1440) <= 5);

% Indices of the events that end at midnight that have corresponding
% events that start at midnight
cont_event_idx = find((end_midnight(1:end-1) & start_midnight(2:end)));

% ... as long as it's the same midnight
cont_event_idx([events(cont_event_idx).end_datenum] ~= [events(cont_event_idx+1).start_datenum]) = [];

for kk = cont_event_idx
	% Get the emission type of this event and the following event and
	% combine them
	emission_types = {};
	for jj = kk:kk+1
		emission_type = events(jj).emission_type;
		while ~isempty(emission_type)
			[token, emission_type] = strtok(emission_type, ', ');
			if ~strcmp(token, 'unchar')
				emission_types{end+1} = token;
			end
		end
	end
	if isempty(emission_types), emission_types = {'unchar'}; end
	emission_types = unique(emission_types); % Remove duplicates
	for jj = 1:length(emission_types)-1, emission_types{jj}(end+1:end+2) = ', '; end
	emission_type = cell2mat(emission_types);
	
	
	% Get the outermost frequency limits
	f_lc = min([events(kk:kk+1).f_lc]);
	f_uc = max([events(kk:kk+1).f_uc]);
	
	% Get the higher intensity
	intensity = max([events(kk:kk+1).intensity]);
	
	% SKIP PARTICLE EVENT, KP, DST
	
	% Combine notes
	if ~isempty(events(kk).notes) && ~isempty(events(kk+1).notes)
		notes = sprintf('%s; %s', events(kk).notes, events(kk+1).notes);
	else
		notes = sprintf('%s%s', events(kk).notes, events(kk+1).notes);
	end
	
	% Write this information to the earlier event
	events(kk).end_datenum = events(kk+1).end_datenum;
	events(kk).f_lc = f_lc;
	events(kk).f_uc = f_uc;
	events(kk).emission_type = emission_type;
	events(kk).intensity = intensity;
	events(kk).notes = notes;
end

% Delete the second half of each two-part event
events(cont_event_idx+1) = [];
