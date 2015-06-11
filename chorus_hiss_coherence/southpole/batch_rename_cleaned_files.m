function batch_rename_cleaned_files
% Rename cleaned south pole files because I screwed it up the first time

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
input_dir = '/media/shackleton/user_data/dgolden/output/southpole_cleaned';

%% Find all .mat files
t_start = now;
find_cmd = sprintf('find %s -iname "*.mat"', input_dir);
[~, filelist_str] = unix(find_cmd);
filelist = textscan(filelist_str, '%s');
filelist = filelist{1};
fprintf('Found %d files in %s\n', length(filelist), time_elapsed(t_start, now));

%% Rename
parfor kk = 1:length(filelist)
  [pathstr, name, ext] = fileparts(filelist{kk});
  if ~isempty(regexpi(name, '^[a-z]{2}_[0-9]{4}_[0-9]{2}_[0-9]{2}T[0-9]{4}_[0-9]{2}_[0-9]{3}_cleaned$'))
    continue;
  end
  
  start_datenum = get_bb_fname_datenum(filelist{kk}, false);
  
  new_filename = sprintf('SP_%s_001_cleaned.mat', datestr(start_datenum, 'yyyy_mm_ddTHHMM_SS'));
  
  movefile(filelist{kk}, fullfile(pathstr, new_filename));
  fprintf('%s -> %s\n', just_filename(filelist{kk}), new_filename)
end
