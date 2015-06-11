function img_datenum = get_img_datenum(fitsfilename)
% img_datenum = get_img_datenum(fitsfilename)
% Extract IMAGE EUV FITS time from filename

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

[pathstr, filename] = fileparts(fitsfilename);
year = str2double(filename(2:5));
doy = str2double(filename(6:8));
hour = str2double(filename(9:10));
min = str2double(filename(11:12));

img_datenum = datenum([year 0 doy hour min 0]);
