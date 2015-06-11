function ecg_write_xls_from_events(events, filename)
% ecg_write_xls_from_events(events)
% Write an XLS file from an events struct

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

% Get the field names for the events struct
names = fieldnames(events);

% Pseudo-preallocate space for the Excel matrix of values
array = cell(length(events) + 1, length(names));

% Assign the header row
array{1,1} = 'Start';
array{1,2} = 'End';
for ll = 3:length(names)
	array{1,ll} = names{ll};
end

% Assign the values
for kk = 1:length(events)
	for ll = 1:length(names)
		if strcmp(names{ll}, 'start_datenum') || strcmp(names{ll}, 'end_datenum')
			array{kk+1,ll} = datestr(events(kk).(names{ll}), 'mm/dd/yyyy');
		else
			array{kk+1,ll} = events(kk).(names{ll});
		end
	end
end

% Write the XLS file
xlswrite(filename, array);
