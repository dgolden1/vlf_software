function TS04_parse_file(TS04_filename)
% Function to parse out necessary parameters for running the TS04 Tsyganenko
% magnetic field model from OMNI_5m_with_TS05_variables files
% 
% TS04_parse_file(TS04_filename)
% 
% Files can be downloaded from
% http://geo.phys.spbu.ru/~tsyganenko/TS05_data_and_stuff/
% 
% Files will be automatically written to .mat files with the same name as
% the input file (with the extension changed)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

[fid, msg] = fopen(TS04_filename);
if fid == -1
	error('Error opening %s: %s', TS04_filename, msg);
end

A = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');

year = A{1};
doy = A{2};
hour = A{3};
min = A{4};
TS04_date = datenum([year zeros(size(year)) doy hour min zeros(size(year))]);

Pdyn = A{17};
ByIMF = A{6};
BzIMF = A{7};
W = [A{18} A{19} A{20} A{21} A{22} A{23}];

[pathname, fname] = fileparts(TS04_filename);
if isempty(pathname)
  [pathname, fname] = fileparts(which(TS04_filename)); % User can just enter the filename with no path
end

output_fullfilename = fullfile(pathname, [fname '.mat']);
save(output_fullfilename, 'TS04_date', 'Pdyn', 'ByIMF', 'BzIMF', 'W');

disp(sprintf('Saved %s', output_fullfilename));
