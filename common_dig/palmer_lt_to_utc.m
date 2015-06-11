function utc = palmer_lt_to_utc(lt)
% utc = palmer_lt_to_utc(lt)
% Returns utc time from palmer local time
% 
% INPUTS
% lt: Palmer local time in Matlab datenum format

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 16, 2007
% $Id$

palmer_longitude = -64.05;
utc = lt - palmer_longitude/360;


% OLD VERSION
% hour_lt = floor(lt/100);
% minute_lt = floor(lt - hour_lt*100);
% hour_dec_lt = hour_lt + minute_lt/60;
% 
% palmer_longitude = -64.05;
% 
% hour_dec_utc = mod(hour_dec_lt - palmer_longitude/15, 24);
% hour_utc = floor(hour_dec_utc);
% minute_utc = (hour_dec_utc - hour_utc)*60;
% 
% utc = floor(hour_utc*100 + minute_utc);
