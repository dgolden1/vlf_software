function pos_struct = parse_cluster_pos_file(filename)
% pos_struct_vec = parse_cluster_pos_file(filename)
% Parse a file of position information obtained for the cluster spacecraft
% from http://sscweb.gsfc.nasa.gov/cgi-bin/sscweb/Locator.cgi
% 
% On that web site, enable the following settings:
% **Spacecraft/Time Range Selection
%  *Select all four cluster spacecraft
%  *Display 1 out of every 5 points
% **Output Options
%  *Check GEO XYZ, LAT/LON
%  *Check Values -> Radial Distance
%  *Check B-field trace -> GEO: NORTH,SOUTH Footpoint Lat/Lon, Field Line Length
%  Footpoint Lat/Lon
% **Click Submit query and wait for output
% 
% Then, copy the entire text output
% Lines 51 and 52 are the headers, and should look exactly like the
% following (including white space):
%       Time     Sat.                 GEO (RE)                  GEO      geoLT     NorthBtrace GEO         SouthBtrace GEO       Radius 
% yyyy ddd hh:mm               X          Y          Z       Lat   Long  hh:mm   Lat   Long    ArcLen    Lat   Long    ArcLen     (RE)  
% 
% Data starts on line 54

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
[fid, msg] = fopen(filename, 'r');
if fid < 1
	error(msg);
end

%% Confirm file is in the correct format
found_header = false;
while ~feof(fid)
	line = fgetl(fid);
	if strcmp(line, '      Time     Sat.                 GEO (RE)                  GEO      geoLT     NorthBtrace GEO         SouthBtrace GEO       Radius ');
		found_header = true;
		break;
	end
end
if ~found_header
	error('Unable to find header in file ''%s''', filename);
end

% Navigate to the start of the data
line = fgetl(fid);
assert(strcmp(line, 'yyyy ddd hh:mm               X          Y          Z       Lat   Long  hh:mm   Lat   Long    ArcLen    Lat   Long    ArcLen     (RE)  '));
line = fgetl(fid);
assert(isempty(line));

pos_data_start = ftell(fid);

%% Count number of lines of data in file
num_lines = 0;
while ~feof(fid)
	line = fgetl(fid);
	num_lines = num_lines + 1;
end

disp(sprintf('Number of data lines = %d', num_lines));

%% Initialize output struct
pos_struct = struct('date', 0, 'sat', 0, 'geore', [0 0 0], 'geolatlon', [0 0], ....
	'geoLT', 0, 'northbtrace', [0 0 0], 'southbtrace', [0 0 0], 'r', 0);
pos_struct = repmat(pos_struct, num_lines, 1);

%% Parse data, fill output struct
fseek(fid, pos_data_start, 'bof');

kk = 1;
while ~feof(fid)
	if kk > num_lines
		error('Error in line count calculation; calculated lines=%d, current line=%d', ...
			num_lines, kk);
	end
	
	line = fgetl(fid);
	year = str2double(line(1:4));
	doy = str2double(line(6:8));
	hour = str2double(line(10:11));
	min = str2double(line(13:14));
	pos_struct(kk).date = datenum([year 0 doy hour min 0]);
	
	pos_struct(kk).sat = str2double(line(23));
	
	pos_struct(kk).geore = str2double({line(25:34), line(36:45), line(47:56)});
	
	pos_struct(kk).geolatlon = str2double({line(58:63), line(65:70)});
	
	hour = str2double(line(72:73));
	min = str2double(line(75:76));
	pos_struct(kk).geoLT = datenum([0 0 0 hour min 0]);
	
	pos_struct(kk).northbtrace = str2double({line(78:83), line(85:90), line(92:100)});

	pos_struct(kk).southbtrace = str2double({line(102:107), line(109:114), line(116:124)});
	
	pos_struct(kk).r = str2double(line(126:134));
	
	kk = kk + 1;
end
