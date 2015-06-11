function [epoch, ae, al, au, ao] = ae_read_datenum(year, ae_filename)
% [epoch, ae] = ae_read_datenum(year, ae_filename)
% Function to parse AE data from the Kyoto web site
% 
% Acquire data from here:
% http://swdcwww.kugi.kyoto-u.ac.jp/dstae/index.html (15 min)
% http://wdc.kugi.kyoto-u.ac.jp/aeasy/index.html (1 min)
% Data format: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/format/aehformat.html
% 
% Supply EITHER year OR ae_filename

% By Daniel Golden (dgolden1 at stanford dot edu) June, 2008
% $Id$

%% Setup
error(nargchk(0, 2, nargin));

%% Read the mat file if no filename is specified
if ~exist('ae_filename', 'var') || isempty(ae_filename)
% 	ae_filename = sprintf('ae_%04d.txt', year);
	ae_filename = 'ae.mat';
  
  load(ae_filename, 'ae', 'epoch');
  
  if exist('year', 'var') && ~isempty(year)
    [yy, ~] = datevec(epoch);
    b = yy == year;
    epoch = epoch(b);
    ae = ae(b);
  end
  
  return;
end

%% Otherwise, parse the text file
[fid, message] = fopen(ae_filename);
if fid == -1
	error(message);
end

line = fgetl(fid);
frewind(fid);
if strcmp(line(1:8), 'AEALAOAU')
  [epoch, ae, al, au, ao] = read_minutely(fid);
elseif strcmp(line(1:6), 'ASYSYM')
  error('Unable to parse ASYSYM files; choose AE format instead');
else
  [epoch, ae, al, au, ao] = read_hourly(fid);
end

function [epoch, ae, al, au, ao] = read_hourly(fid)
%% Function: read 1-hour AE file

C = textscan(fid, '%2c %02f%02f*%02f X%*c%106c');
type = num2cell(C{1}, 2);
year = C{2} + str2double(num2cell(C{5}(:, (15:16)-14), 2))*100;
month = C{3};
day = C{4};
baseval = str2double(num2cell(C{5}(:, (17:20)-14), 2));
dailymean = str2double(num2cell(C{5}(:, (117:120)-14), 2));
vals_mat = zeros(size(C{1}, 1), 24);
for kk = 1:24
  vals_mat(:,kk) = str2double(num2cell(C{5}(:, (21:24) + (kk-1)*4 - 14), 2));
end
vals = flatten(vals_mat.');
day_vec = datenum([year month day zeros(length(year), 3)]);
[day_mat, hour_mat] = ndgrid(day_vec, (0:23)/24);
epoch_full = flatten((day_mat + hour_mat).');
for kk = 1:24
  type_full(kk:24:length(type)*24, 1) = type;
end

ae = vals(strcmpi(type_full, 'AE'));
epoch = epoch_full(strcmpi(type_full, 'AE'));
al = vals(strcmpi(type_full, 'AL'));
ao = vals(strcmpi(type_full, 'AO'));
au = vals(strcmpi(type_full, 'AU'));

% Make sure there are no jumps in the dates
assert(all(abs(median(diff(epoch)) - diff(epoch)) < 1/86400));

function [epoch, ae, al, au, ao] = read_minutely(fid)
%% Function: read 1-minute AE file

C = textscan(fid, ['%*12c %02f %02f %02f %*c %02f %2c %*10c ' ...
  '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' ...
  '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' ...
  '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' ...
  '%f']);

year = 1900 + C{1} + 100*(C{1} < 50); % 19-- if year is 50 or above, 20-- if year is 49 or below
month = C{2};
day = C{3};
hour = C{4};
component = num2cell(C{5}, 2);
vals = cell2mat(C(6:65));

[datenum_remainder, datenum_minute] = ndgrid(datenum([year month day hour zeros(length(year), 2)]), (0:59)/1440);
epoch_full = datenum_remainder + datenum_minute;

ae = flatten(vals(strcmp(component, 'AE'), :).');
epoch = flatten(epoch_full(strcmp(component, 'AE'), :).');
al = flatten(vals(strcmp(component, 'AL'), :).');
assert(all(epoch == flatten(epoch_full(strcmp(component, 'AL'), :).')));
ao = flatten(vals(strcmp(component, 'AO'), :).');
assert(all(epoch == flatten(epoch_full(strcmp(component, 'AO'), :).')));
au = flatten(vals(strcmp(component, 'AU'), :).');
assert(all(epoch == flatten(epoch_full(strcmp(component, 'AU'), :).')));
