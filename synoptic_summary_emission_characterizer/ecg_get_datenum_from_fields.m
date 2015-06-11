function date_num = ecg_get_datenum_from_fields(date_field, time_field, bRoundUp)
% date_num = ecg_get_datenum_from_fields(date_field, time_field, bRoundUp)
% Set bRoundUp to true if midnight should round up to the next day

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

if ~exist('bRoundUp', 'var') || isempty(bRoundUp), bRoundUp = false; end

assert(length(date_field) == 10);
assert(date_field(3) == '/');
assert(date_field(6) == '/');
midnight = datenum(date_field, 'mm/dd/yyyy');

assert(length(time_field) == 5);
assert(time_field(3) == ':');
HH = str2double(time_field(1:2));
MM = str2double(time_field(4:5));
date_num = midnight + (HH + MM/60)/24;

% If the time is midnight and we're supposed to round it up, round it up
if bRoundUp && fpart(date_num) == 0, date_num = date_num + 1; end
