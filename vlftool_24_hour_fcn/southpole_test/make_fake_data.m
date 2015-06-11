function make_fake_data
% Use a single Synoptic data file from South Pole to create a fake days'
% worth of synoptic data, on which I can test my 24-hour spectrogram script

% By Daniel Golden (dgolden1 at stanford dot edu) April 2011
% $Id$

source_dir = '/home/dgolden/temp/southpole_data/original';
dest_dir = '/home/dgolden/temp/southpole_data';
source_filenames = {'SP110401000000_000.mat', 'SP110401000000_001.mat'};

start_datenums = datenum([2011 04 01 0 0 0]):5/1440:datenum([2011 04 01 23 55 00]);

for file_num = 1:2
  source_full_filename = fullfile(source_dir, source_filenames{file_num});
  for kk_start_datenum = 1:length(start_datenums)
    t_start = now;
    create_new_file(source_full_filename, dest_dir, start_datenums(kk_start_datenum));
    
    fprintf('Wrote file %d of %d in %s\n', (file_num - 1)*length(start_datenums) + kk_start_datenum, ...
      2*length(start_datenums), time_elapsed(t_start, now));
  end
end

function create_new_file(original_full_filename, dest_dir, new_date)

FS = load(original_full_filename);
[yy, mm, dd, HH, MM, SS] = datevec(new_date);

FS.start_year = yy;
FS.start_month = mm;
FS.start_day = dd;
FS.start_hour = HH;
FS.start_minute = MM;
FS.start_second = SS;

channel_and_ext = original_full_filename(end - 7:end);
new_filename = sprintf('SP%s%s', datestr(new_date, 'yymmddHHMMSS'), channel_and_ext);

new_full_filename = fullfile(dest_dir, new_filename);
write_twochannel_data(new_full_filename, FS, FS.data);

fprintf('Wrote %s\n', new_full_filename);
