function vlf_spec_multi(db_low, db_high, f_high, filenames, pathname, JPEGLocation)
% vlf_spec_multi(db_low, db_high, f_high, filenames, pathname, JPEGLocation)
% Function to select and process multiple broadband files with vlf_spec
% Currently only works with INTERLEAVED PALMER DATA (as of 04/25/2007)
% 
% INPUTS
% db_low: lower level of colorbar in dB
% db_high: higher level of colorbar in dB
% f_high: upper cutoff frequency (in kHz)
% 
% By Daniel Golden (dgolden1 at stanford dot edu) Apr 25, 2007

% $Id$

%% Setup
TypeOfData = 2; % Palmer 100 kHz interleaved data only!
total_time = 0;

if ~exist('db_low', 'var'),  db_low = []; end
if ~exist('db_high', 'var'), db_high = []; end
if ~exist('f_high', 'var'), f_high = []; end

%% Chose input files and output dir
if ~exist('filenames', 'var') || isempty(filenames)
  if exist(pathname) && ~isempty(pathname)
    [filenames, pathname] = uigetfile(fullfile(pathname, '*.mat;*.MAT;'), 'Choose broadband file(s)', ...
      'MultiSelect', 'On');
  else
    [filenames, pathname] = uigetfile('*.mat;*.dat;*.raw', 'Choose broadband file(s)', ...
      'MultiSelect', 'On');
  end
  if ~iscell(filenames) && isequal(filenames, 0), return; end % Quit if user pressed 'cancel'
end
if ~exist('JPEGLocation', 'var') || isempty(JPEGLocation)
  JPEGLocation = uigetdir([], 'Choose JPEG output directory');
  if JPEGLocation == 0, return; end % Quit if user pressed 'cancel'
end
disp(sprintf('Selected output directory: %s', JPEGLocation));

if ~iscell(filenames)
  filestr = filenames;
  filenames = cell(1,1);
  filenames{1} = filestr;
end

%% Run vlf_spec
for kk = 1:length(filenames)
  disp(sprintf('Processing file %s...', filenames{kk}));
  [iteration_time] = vlf_spec(TypeOfData, JPEGLocation, fullfile(pathname, filenames{kk}), db_low, db_high, f_high);
  [iteration_minutes, iteration_seconds] = sec2minsec(iteration_time);
  disp(sprintf('Processed file %s in %d minutes, %d seconds', filenames{kk}, iteration_minutes, iteration_seconds));

  total_time = total_time + iteration_time;
end
% else % Otherwise, if the user only picked one input file...
%   disp(sprintf('Processing file %s', filenames));
%   [iteration_time] = vlf_spec(TypeOfData, JPEGLocation, [pathname filenames]);
%   total_time = total_time + iteration_time;
% end

[total_time_minutes, total_time_seconds] = sec2minsec(total_time);
disp(sprintf('Processed %d files in %d minutes, %d seconds', length(filenames), total_time_minutes, total_time_seconds));

%% Function: sec2minsec
function [minutes, seconds] = sec2minsec(total_seconds)
% [minutes, seconds] = sec2minsec(total_seconds)
% Converts a time in seconds to a time in minutes and seconds (both rounded down)
% 
% By Daniel Golden (dgolden1 at stanford dot edu) Apr 25 2007

minutes = floor(total_seconds/60);
seconds = floor(total_seconds - minutes*60);
