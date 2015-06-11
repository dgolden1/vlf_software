function FS = convert_themis_ephemeris_ascii_to_mat(input_filename, output_filename)
% Convert THEMIS ephemeris data from text file format from
% http://sscweb.gsfc.nasa.gov/ to .mat file format
% 
% Header must be as follows:
%       Time                  SM (RE)               SM    smLT
% yyyy ddd hh:mm      X          Y          Z       Lat  hh:mm  DipL-Val

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

headerlines = 38;

fid = fopen(input_filename);
C = textscan(fid, '%f %f %f:%f %f %f %f %f %f:%f %f', 'headerlines', headerlines);
FS.datenum = datenum([C{1} ones(size(C{1})) C{2} C{3} C{4} zeros(size(C{1}))]);
FS.xyz_sm = [C{5} C{6} C{7}];
FS.lat = C{8};
FS.MLT = C{9} + C{10}/60;
FS.L = C{11};

save(output_filename, '-struct', 'FS');

fclose(fid);
