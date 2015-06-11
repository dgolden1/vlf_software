function emission_superposed_epoch
% emission_superposed_epoch
% Plot a superposed epoch analysis of chorus from Palmer based on minimum
% Dst

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
persistent dst dst_date % Big databases to load

dst_thresh = -50; % nT
dst_epoch_closeness_thresh = 3; % mandate all min dst epochs are this far apart from each other, days

%% Load Dst
% if isempty(dst)
%   dst = [];
%   dst_date = [];
%   for year = 2000:2010
%     [this_dst_date, this_dst] = dst_read_datenum(year);
%     dst = [dst; this_dst];
%     dst_date = [dst_date; this_dst_date];
%   end
%   save('dst_2000_2010.mat', 'dst', 'dst_date');
% end
load('dst_2000_2010.mat');

%% Load emissions
events = load_emissions;

start_datenum = min([events.start_datenum]);
end_datenum = max([events.start_datenum]);

%% Get minimum Dst points
dst_diff = diff(dst);
dst_crossing_down_idx = find(dst(1:end-1) > dst_thresh & dst(2:end) <= dst_thresh) + 1; % Index right after Dst went below dst_thresh
dst_crossing_up_idx = find(dst(1:end-1) <= dst_thresh & dst(2:end) > dst_thresh) + 1; % Index right after Dst went above dst_thresh
assert(all(dst_crossing_up_idx > dst_crossing_down_idx));

% Find min Dst index in each interval
min_dst_idx = nan(size(dst_crossing_down_idx));
min_dst = nan(size(dst_crossing_down_idx));
for kk = 1:length(dst_crossing_down_idx)
  [min_dst(kk), min_dst_idx(kk)] = min(dst(dst_crossing_down_idx(kk):dst_crossing_up_idx(kk)));
  min_dst_idx(kk) = min_dst_idx(kk) + dst_crossing_down_idx(kk) - 1;
end
min_dst_date = dst_date(min_dst_idx);

% If multiple min-dst peaks are within min_dst_time_diff hours of each other, reject all
% but the strongest one
min_dst_time_diff = diff(min_dst_date);
while any(min_dst_time_diff < dst_epoch_closeness_thresh)
%   clf;
%   plot(dst_date, dst);
%   hold on;
%   plot(min_dst_date, min_dst, 'r*');
%   plot([min(dst_date), max(dst_date)], dst_thresh*[1 1], '--', 'color', [0 0.5 0]);
%   grid on
%   datetick2('x');
  
  idx_valid = true(size(min_dst));
  for kk = 1:(length(min_dst) - 1)
    if min_dst_date(kk+1) - min_dst_date(kk) < dst_epoch_closeness_thresh
      if min_dst(kk+1) < min_dst(kk)
        idx_valid(kk) = false;
      else
        idx_valid(kk+1) = false;
      end
    end
  end
  
  min_dst = min_dst(idx_valid);
  min_dst_idx = min_dst_idx(idx_valid);
  min_dst_date = min_dst_date(idx_valid);
  
  fprintf('Removed %d epochs that were too close to each other\n', sum(~idx_valid));
  
  min_dst_time_diff = diff(min_dst_date);
end

%% Superposed Dst
epoch_time = (-dst_epoch_closeness_thresh*24:dst_epoch_closeness_thresh*24)/24;
dst_superposed_mtx = zeros(length(min_dst), length(epoch_time));

for kk = 1:length(min_dst_date)
  dst_superposed_mtx(kk, :) = interp1(dst_date, dst, min_dst_date(kk) + epoch_time, 'linear', 0);
end

%% Superposed chorus
figure;
h_chorus = subplot(2, 1, 1);
set(h_chorus, 'tag', 'chorus_axes');
plot_chorus_superposed_cum_spec(min_dst_date, dst_epoch_closeness_thresh*[-1 1], 'h_ax', h_chorus);
xlabel('');
set(gca, 'xticklabel', []);
title(sprintf('%d events', length(min_dst)));

%% Plot results
% figure;
% plot(dst_date, dst);
% hold on;
% plot(min_dst_date, min_dst, 'r*');
% plot([min(dst_date), max(dst_date)], dst_thresh*[1 1], '--', 'color', [0 0.5 0]);
% grid on
% datetick2('x');
% title('Epochs');
% increase_font;

h_dst = subplot(2, 1, 2);
set(h_dst, 'tag', 'dst_axes');
fill([epoch_time*24, fliplr(epoch_time*24)], [quantile(dst_superposed_mtx, 0.95), fliplr(quantile(dst_superposed_mtx, 0.05))], 0.7*[1 1 1])
hold on;
plot(epoch_time*24, mean(dst_superposed_mtx), 'linewidth', 2);

% plot(epoch_time*24, [mean(dst_superposed_mtx); quantile(dst_superposed_mtx, 0.05); ...
%   quantile(dst_superposed_mtx, 0.95)], 'linewidth', 2);
grid on;
xlabel('Hours from epoch');
ylabel('Dst (nT)');
% title('Superposed Dst');
legend('95th %', 'Mean', 'location', 'southeast');
ylim([-250 20]);
increase_font;

%% Line up axes
pos_ch = get(h_chorus, 'position');
pos_dst = get(h_dst, 'position');
xl_ch = get(h_chorus, 'xlim');
set(h_dst, 'position', [pos_ch(1), pos_dst(2), pos_ch(3), pos_dst(4)], ...
  'xlim', round(xl_ch));
