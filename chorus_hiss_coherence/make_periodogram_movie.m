function make_periodogram_movie
% Make a movie of all of the south pole periodograms

% By Daniel Golden (dgolden1 at stanford dot edu) April 2011
% $Id$

%% Setup
output_dir = '~/temp/southpole_pwelch';
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
jpeg_dir = fullfile(output_dir, 'jpeg');
if exist(jpeg_dir, 'dir'), rmdir(jpeg_dir, 's'); end
mkdir(jpeg_dir);


year = 2001;
year_dir = sprintf('/media/scott/awesome/broadband/southpole/%04d', 2001);
d = dir(year_dir);
day_dirs = {d(cellfun(@(x) ~isempty(regexp(x, '[0-9]{2}_[0-9]{2}', 'once')), {d.name})).name};


window = 2^nextpow2(1e5*0.0064); % Window is at least 6.4 ms long
nfft = window*2;
noverlap = window/2;

%% Loop
for jj = 1:length(day_dirs)
  t_dir_start = now;
  
  [filenames, file_offsets, channel] = get_synoptic_offsets(...
    'pathname', fullfile(year_dir, day_dirs{jj}), 'start_sec', 26, 'which_channel', 'E/W');
  
  for kk = 1:length(filenames)
    data_datenum = get_bb_fname_datenum(filenames{kk}, true);
    if data_datenum < 1
      month = str2double(day_dirs{kk}(1:2));
      day = str2double(day_dirs{kk}(4:5));
      data_datenum = data_datenum + datenum([year month day 0 0 0]);
    end
    
    try
      [data, fs] = get_synoptic_data(filenames{kk}, file_offsets(kk), 10, 'E/W');
    catch er
      warning(sprintf('Unable to retrieve data from %s: %s', filenames{kk}, er.message));
      continue;
    end
    assert(fs == 1e5);
    
    sfigure(1);
    pwelch(data, window, noverlap, nfft, fs);
    title(sprintf('South Pole E/W %s', datestr(data_datenum, 31)));
    increase_font;
    output_filename = fullfile(jpeg_dir, sprintf('SP_%s.jpg', datestr(data_datenum, 'yyyy_mm_dd_HHMM_SS')));
    print('-djpeg95', '-r90', output_filename);
    fprintf('Saved %s\n', output_filename);
  end
  
  fprintf('Finished %s in %s\n', fullfile(year_dir, day_dirs{jj}), time_elapsed(t_dir_start, now));
end
