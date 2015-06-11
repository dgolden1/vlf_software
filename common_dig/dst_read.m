function [year, month, day, hour, min, sec, dst] = dst_read(filename)
% [year, month, day, dst] = dst_read(filename)
% Function to parse DST data from the Kyoto web site
% Acquire data from here: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/index.html
% Data format: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/format/dstformat.html

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 18, 2007
% $Id$

[date, dst] = dst_read_datenum(filename);

date_vec = datevec(date);
year = date_vec(:,1);
month = date_vec(:,2);
day = date_vec(:,3);
hour = date_vec(:,4);
min = date_vec(:,5);
sec = date_vec(:,6);
