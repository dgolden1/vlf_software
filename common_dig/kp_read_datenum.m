function [kp_date, kp] = kp_read_datenum(year, kp_filename)
% [kp_date, kp] = kp_read_datenum(year, kp_filename)
% Function to parse Kp data from the Kyoto web site
% Aquire data from here: http://swdcwww.kugi.kyoto-u.ac.jp/kp/index.html
% Data format: http://swdcwww.kugi.kyoto-u.ac.jp/kp/format.html

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2007
% $Id$

%% Setup
error(nargchk(0, 2, nargin));

%% Read the mat file if no filename is specified
if ~exist('kp_filename', 'var') || isempty(kp_filename)
	kp_filename = sprintf('kp.mat');

  load(kp_filename, 'kp', 'kp_date');

  if exist('year', 'var') && ~isempty(year)
    [yy, ~] = datevec(kp_date);
    b = yy == year;
    kp_date = kp_date(b);
    kp = kp(b);
  end
  
  return;
end

%% Otherwise, parse the text file
[fid, message] = fopen(kp_filename);
if fid == -1
	error('Error reading %s: %s', kp_filename, message);
end

%% Preallocate kp matrix
% Count lines
numlines = 0;
while ~feof(fid)
	line = fgetl(fid);
	if length(line) < 8 || strcmp(line(1:8), 'YYYYMMDD'), continue; end
	
	% Each line begins with a number of the form YYYYMMDD
	if ~isnan(str2double(line(1:8)))
		numlines = numlines + 1;
	end
end
frewind(fid); % Rewind file

kp_date = zeros(numlines*8, 1);
kp = zeros(numlines*8, 1);

%% Parse File
lineno = 1;
while ~feof(fid)
	line = fgetl(fid);

	if length(line) < 8 || strcmp(line(1:8), 'YYYYMMDD'), continue; end
	
	day = datenum(line(1:8), 'yyyymmdd');
	i = 10;
	for kk = 1:8
		idx = (lineno-1)*8 + kk;
		kp_date(idx) = day + 1.5/24 + 3/24*(kk-1);
		kp(idx) = str2double(line(i));
		if line(i+1) == '+'
			kp(idx) = kp(idx) + 1/3;
		elseif line(i+1) == '-'
			kp(idx) = kp(idx) - 1/3;
		else
			assert(line(i+1) == ' ');
		end
		i = i + 2;
	end

	lineno = lineno + 1;
end

fclose(fid);
