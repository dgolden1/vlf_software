function lt = utc_to_palmer_lt(utc)
% lt = utc_to_palmer_lt(utc)
% Returns palmer local time from utc time
% 
% INPUTS
% utc: UTC in Matlab datenum format

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 16, 2007
% $Id$

PALMER_T_OFFSET = -(4+1/60)/24;
lt = utc + PALMER_T_OFFSET;

% OLD VERSION
% hour_utc = floor(utc/100);
% minute_utc = floor(utc - hour_utc*100);
% hour_dec_utc = hour_utc + minute_utc/60;
% 
% palmer_longitude = -64.05;
% 
% hour_dec_lt = mod(hour_dec_utc + palmer_longitude/15, 24);
% hour_lt = floor(hour_dec_lt);
% minute_lt = (hour_dec_lt - hour_lt)*60;
% 
% lt = floor(hour_lt*100 + minute_lt);
