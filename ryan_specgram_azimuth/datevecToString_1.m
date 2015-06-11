function outString = datevecToString(T)

%outString format:
%yyyy/mm/dd HH:MM:SS.SSSSSSS

%(resolution to 10 microseconds)
date_number = datenum([T(1:5) floor(T(6))]);
secFloor = floor(T(6));
outString = [datestr(date_number,26) ' ' datestr(date_number,13) '.' sprintf('%07d',floor(1e7*(T(6)-secFloor+1e-10)))];
