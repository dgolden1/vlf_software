function [filenames_out, file_offsets, channel] = get_data_server_file_offsets(sitename, start_datenums, duration, which_channel)
% [filenames_out, file_offsets] = get_data_server_file_offsets(sitename, start_datenums, duration)
% Specify a site and a list of start times and duration, and this function
%  returns a list of files on the data server which contain those
%  intervals.
% 
% INPUTS
% sitename: scott data folder name
% start_datenums: list of data segment start times.  Must all be on the
% same day
% duration: data segment lengths
% which_channel: either 'N/S', 'E/W' or 'both' (default: default for
%  get_synoptic_offsets)
% 
% OUTPUTS
% filenames_out: list of output filenames
% file_offsets: start second for each filename

if ~all(floor(start_datenums) == floor(start_datenums(1)))
  error('All start datenums must be on the same day');
end

pathname = fullfile(scottdataroot, 'awesome', 'broadband', sitename, datestr(start_datenums(1), 'yyyy/mm_dd'));
d = [dir(fullfile(pathname, '*.mat')); dir(fullfile(pathname, '*.MAT'))];
filenames = {d.name};

if exist('which_channel', 'var') && ~isempty(which_channel)
  [filenames_out, file_offsets, channel] = get_synoptic_offsets('pathname', pathname, 'filenames_in', filenames, ...
                                                       'specific_datenums', start_datenums, ...
                                                       'duration', duration, 'which_channel', which_channel);
else
  [filenames_out, file_offsets, channel] = get_synoptic_offsets('pathname', pathname, 'filenames_in', filenames, ...
                                                       'specific_datenums', start_datenums, ...
                                                       'duration', duration);
end
