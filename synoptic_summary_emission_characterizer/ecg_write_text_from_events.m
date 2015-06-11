function ecg_write_text_from_events(events, filename)
% ecg_write_text_from_events(events, filename)
% Write a tab-separated file from an events struct

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

[fid, message] = fopen(filename, 'w');
if fid == -1, error(message); end

% Sort events
events = ecg_sort_events(events);

% Get the field names for the events struct
names = fieldnames(events);

% Print header rows
fprintf(fid, 'Start\tEnd\t');
for kk = 3:length(names)
	fprintf(fid, '%s\t', names{kk});
end
fprintf(fid, '\n');

for kk = 1:length(events)
	for ll = 1:length(names)
		val = events(kk).(names{ll});
		if strcmp(names{ll}, 'start_datenum') || strcmp(names{ll}, 'end_datenum')
			fprintf(fid, '%s\t', datestr(val, 'mm/dd/yyyy HH:MM'));
		else
			if isempty(val)
				fprintf(fid, '\t');
			elseif ischar(val)
				fprintf(fid, '%s\t', val);
			elseif isnumeric(val)
				fprintf(fid, '%g\t', val);
			else
				error('Weird data type in events');
			end
		end
	end
	fprintf(fid, '\n');
end
