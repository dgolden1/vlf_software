function [fs_new, new_filename] = subsample_resave_data(input_file, output_dir, f_uc, new_suffix)
% [fs_new, new_filename] = subsample_resave_data(input_file, output_dir, f_uc, new_suffix)
% Function to decimate data and resave it (saves disk space). 2-channel
% AWESOME data only - no interleaved.
% 
% INPUTS
% f_uc: upper cutoff frequency (in Hz). Sampling frequency of resampled
%  data will be at this frequency OR HIGHER. Default = 10e3 Hz
% new_suffix: suffix to append to output filename. Default = ''
% 
% OUTPUTS
% f_uc_new: sample rate of output file (Hz)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
if ~exist('f_uc', 'var') || isempty(f_uc)
	f_uc = 10e3;
end
if ~exist('new_suffix', 'var') || isempty(new_suffix)
	new_suffix = '';
end

%% Decimate and rewrite data
s = load(input_file);
subsample_rate = floor((s.Fs/2)/f_uc);
s.Fs = s.Fs/subsample_rate;
fs_new = s.Fs;

data = decimate(s.data, subsample_rate);

[pathstr, name, ext] = fileparts(input_file);
new_filename = fullfile(output_dir, [name new_suffix ext]);

write_twochannel_data(new_filename, s, data);
