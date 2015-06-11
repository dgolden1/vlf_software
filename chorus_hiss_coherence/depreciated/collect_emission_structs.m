function collect_emission_structs(input_dir, output_dir)
% collect_emission_structs(input_dir, output_dir)
% Function to collect emission structs that are processed daily, and
% combine them into one big emission struct

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 2009
% $Id$

%% Set paths
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    default_input_dir = '/media/amundsen/user_data/dgolden/temp/burstiness';
    default_output_dir = '~/temp';
  case 'scott.stanford.edu'
    default_input_dir = '/home/dgolden/dgolden_data/burstiness/2001';
    default_output_dir = '/data/user_data/dgolden/temp/';
  otherwise
    error('Unknown hostname ''%s''', hostname(1:end-1));
end

if ~exist('input_dir', 'var') || isempty(input_dir)
  input_dir = default_input_dir;
end
if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = default_output_dir;
end

%% List directories
d = dir(fullfile(input_dir, 'auto_chorus_hiss_*'));
d = d([d.isdir]);

%% Gather db files
events = [];
fprintf('Gathering database files from %s...\n', input_dir);
for kk = 1:length(d)
  matfile = dir(fullfile(input_dir, d(kk).name, '*.mat'));
  if isempty(matfile)
    fprintf('Missing database file from %s\n', d(kk).name);
  else
    this_full_filename = fullfile(input_dir, d(kk).name, matfile.name);
    this_events = load(this_full_filename, 'events');
    events = [events; this_events.events];
    fprintf('Processed %s\n', matfile.name);
  end
end


%% Save the new db file
output_db_full_filename = fullfile(output_dir, 'auto_chorus_hiss_db.mat');
% if exist(output_db_full_filename, 'file')
%   db = load(output_db_full_filename);
% 
%   first_db_datenum = min([db.events.start_datenum]);
%   last_db_datenum = max([db.events.start_datenum]);
%   
%   first_collected_datenum = datenum([year str2double(d(1).name(18:19)) str2double(d(1).name(21:22)) 0 0 0]);
%   last_collected_datenum = datenum([year str2double(d(end).name(18:19)) str2double(d(end).name(21:22)) 0 0 0]);
%   
%   disp(sprintf('\nWARNING: output file %s\n exists and has events from %s to %s\n', ...
%     output_db_full_filename, datestr(first_db_datenum, 31), datestr(last_db_datenum, 31)));
%   disp(sprintf('This script collected events from %s to %s\n', datestr(first_collected_datenum, 29), datestr(last_collected_datenum, 29)));
%   
%   min_required_start_datenum = floor(last_db_datenum + 1);
%   disp(sprintf('Only emissions on or after %s will be merged with the existing database\n', datestr(min_required_start_datenum, 29)));
%   
%   events = events([events.start_datenum] >= min_required_start_datenum);
%   
%   events = [db.events; events];
%   
%   save(output_db_full_filename, 'events');
% else
  save(output_db_full_filename, 'events');
% end

disp(sprintf('Saved %s', output_db_full_filename));
