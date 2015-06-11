function convert_gld360_text_to_bin(source_filename, source_dir, dest_dir)
% convert_gld360_text_to_bin(source_filename, source_dir, dest_dir)
% Convert ASCII GLD360 files to Matlab files
% 
% INPUTS
% source_filename (optional): an .asc file to convert.  If none given, run
% on all files in source_dir
% source_dir (optional): source directory for .asc files to convert.  Not
% needed if source_filename is given.
% dest_dir (optional): output directory of .mat files.  Defaults to
% source_dir or directory of source_filename.

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Run on one file or directory
if ~exist('source_filename', 'var') || isempty(source_filename)
  fprintf('Running on all files in %s\n', source_dir);
  
  if ~exist('dest_dir', 'var') || isempty(dest_dir)
    dest_dir = source_dir;
  end

  d = dir(fullfile(source_dir, '*.asc'));

  for kk = 1:length(d)
    convert_single_file(fullfile(source_dir, d(kk).name), dest_dir);
  end
else
  fprintf('Running on %s\n', source_filename);

  if ~exist('dest_dir', 'var') || isempty(dest_dir)
    dest_dir = fileparts(source_filename);
  end
  
  convert_single_file(source_filename, dest_dir);
end

function convert_single_file(input_filename, dest_dir)
%% Convert a single .asc file to a .mat file
fid = fopen(input_filename);

t_start = now;
[~, name, ext] = fileparts(input_filename);
fprintf('Reading %s\n', [name ext]);

C = textscan(fid, '%f-%f-%f %f:%f:%f %f %f %*f %*f %*f %*f %*f %*f');
fprintf('Read %d lines in %s\n', length(C{1}), time_elapsed(t_start, now));
fclose(fid);

% Convert to output struct
gld360.date = datenum([C{1} C{2} C{3} C{4} C{5} C{6}]);
gld360.nstrokes = ones(size(C{1}));
gld360.lat = C{7};
gld360.lon = C{8};
gld360.peakcur = zeros(size(C{1})); % Initial version of GLD360 does not have correct peak current values

[yy, mm, dd, HH, MM, SS] = datevec([max(gld360.date), min(gld360.date)]);
if mm(1) ~= mm(2)
  error('Input file contains data from more than one month');
end

output_filename = fullfile(dest_dir, ['gld360_' datestr(gld360.date(1), 'yyyy_mm'), '.mat']);
save(output_filename, '-struct', 'gld360');

fprintf('Saved %s (t = %s)\n', output_filename, time_elapsed(t_start, now));
