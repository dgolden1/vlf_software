function vlf_24hrsynspec_from_24hrcont(yyyy_mm_dd, b_ftp_file, cont_source_path, synop_temp_path, destin_path)
% vlf_24hrsynspec_from_24hrcont(yyyy_mm_dd, b_ftp_file, cont_source_path, synop_temp_path, destin_path)
% Script to make a 24-hour synoptic spectrogram from 24-hour continuous
% data
% 
% This is a script version of the vlfGuiReduced GUI
% 
% yyyy_mm_dd is a 3-element vector (e.g., [2008 01 12] for Jan 12, 2008)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
if ~exist('b_ftp_file', 'var') || isempty(b_ftp_file)
  b_ftp_file = true;
end

global DF;
vlfDefaults;

if ~exist('destin_path', 'var')
  [stat, hostname] = unix('hostname');
  switch(hostname(1:end-1))
    case 'quadcoredan.stanford.edu'
      cont_source_path = '/media/scott/awesome/broadband/palmer/2008/01_12/';
      synop_temp_path = '/home/dgolden/temp/synoptic_files/';
      destin_path = '/home/dgolden/temp/synoptic_files/';
    otherwise
      cont_source_path = 'G:\Continuous\';
      synop_temp_path = 'C:\VLFtool_data\';
      destin_path = 'C:\VLFtool_data\';
  end
end

if ~exist('yyyy_mm_dd', 'var') || isempty(yyyy_mm_dd)
  % yyyy_mm_dd = [2009 05 21];
  yyyy_mm_dd = datevec(floor(now) - 0.25); % The day that was 6 hours ago - this runs around midnight UT at Palmer, so this should be the day that just passed
end
yyyy_mm_dd = yyyy_mm_dd(1:3);

%% Process
% Delete contents of temp directory
d = [dir(fullfile(synop_temp_path, '*_002.mat')); dir(fullfile(synop_temp_path, '*_003.mat'))];
if ~isempty(d)
%   button = questdlg(sprintf('Warning: temp directory (''%s'') contains synoptic files. Are you sure you want to delete them?', ...
%     synop_temp_path), 'Warning', 'Yes', 'No', 'Yes');
%   if strcmp(button, 'No')
%     disp('Synoptic directory must be empty before proceeding');
%     return;
%   else
    for kk = 1:length(d)
      delete(fullfile(synop_temp_path, d(kk).name));
    end
    disp(sprintf('Deleted %d files from temporary directory', length(d)));
%   end
end

% Create synoptic files
t_start = now;
disp('Creating synoptic files');

% Start 10 seconds into the files to avoid the Palmer caltone
if ~exist(cont_source_path, 'dir')
  error('%s does not exist!', cont_source_path);
end
new_filelist = reduce_30min_to_synoptic(cont_source_path, [], synop_temp_path, 1, [5 20 35 50]+10/60, 5, yyyy_mm_dd, false);
if isempty(new_filelist)
  disp(sprintf('No continous files found for %s in ''%s''', ...
    datestr(datenum([yyyy_mm_dd 0 0 0])), cont_source_path));
  return;
end

disp(sprintf('Files created in %s', time_elapsed(t_start, now)));


% Run the processing on the newly-created synoptic files
t_start = now;
disp('Creating synoptic spectrogram');

DF.VLF.UT = [];
DF.VLF.freq = [];
DF.VLF.psd = [];
vlf_process_24_dan(synop_temp_path, destin_path);

t_end = now;
disp(sprintf('Processing completed in %0.0f seconds', (t_end - t_start)*86400));


% And remove the synoptic files
for kk = 1:length(new_filelist)
  delete(new_filelist{kk});
end

%% FTP the JPEG
% if b_ftp_file
%   load ftp_credentials.mat;
%   f = ftp('nova.stanford.edu', l, p);
%   cd(f, '/public_html/hardware/fieldsites/palmer/daily');
% 
%   % Convert year in yyyy_mm_dd to a 4-digit year
%   if yyyy_mm_dd(1) < 50
%     yyyy_mm_dd(1) = yyyy_mm_dd(1) + 2000;
%   elseif yyyy_mm_dd(1) < 100
%     yyyy_mm_dd(1) = yyyy_mm_dd(1) + 1000;
%   end
%   img_mask = fullfile(destin_path, sprintf('palmer_%s*.png', datestr(datenum([yyyy_mm_dd 0 0 0]), 'yyyymmdd')));
%   d = dir(img_mask);
%   for kk = 1:length(d)
%     mput(f, fullfile(destin_path, d(kk).name));
%     disp(sprintf('Uploaded %s to %s', d(kk).name, ['http://www-star.stanford.edu/~vlf/hardware/fieldsites/palmer/daily/' d(kk).name]));
%   end
%   close(f);
% end

%% SCP the JPEG
if b_ftp_file
  % Convert year in yyyy_mm_dd to a 4-digit year
  if yyyy_mm_dd(1) < 50
    yyyy_mm_dd(1) = yyyy_mm_dd(1) + 2000;
  elseif yyyy_mm_dd(1) < 100
    yyyy_mm_dd(1) = yyyy_mm_dd(1) + 1000;
  end
  img_mask = sprintf('palmer_%s*.png', datestr(datenum([yyyy_mm_dd 0 0 0]), 'yyyymmdd'));

  cwd = pwd;
  cd(destin_path);
  cmd = sprintf('scp %s vlf-sftp@vlf-alexandria.stanford.edu:~/scott_outbox/files/', img_mask);
  disp(cmd);
  system(cmd);
  cd(cwd);
end
