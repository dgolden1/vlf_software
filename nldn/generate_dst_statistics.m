function generate_dst_statistics
% generate_dst_statistics
% Save a vector of mean DST values in 1-hour bins from 2003

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
output_dir = '/home/dgolden/vlf/case_studies/nldn/statistics';

date_start = datenum([2003 01 01 0 0 0]);
date_end = datenum([2003 11 1 0 0 0]);
hour = (date_start:1/24:date_end).';

%% Read and convert Dst
[date, dst] = dst_read_datenum(date_start, date_end);

% Dst is an hourly index that is some sort of "average" of the previous hour; the
% first hour is 0100, so it's offset by 1 hour from our requested date.
% Interpolate the 0000 point.
dst = interp1(date, dst, hour, 'linear', 'extrap');
%% Save result
save(fullfile(output_dir, 'dst_statistics.mat'), 'dst', 'hour');

figure;
plot(hour, dst, 'LineWidth', 2);
grid on;
xlim([date_start date_end]);
datetick('x', 'keeplimits');
xlabel('Date');
ylabel('Dst (nT)');

disp('');
