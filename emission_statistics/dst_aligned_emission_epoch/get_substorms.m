function [ss_min_dst ss_min_date] = get_substorms(start_date, end_date, epoch_win_start, epoch_win_end, b_plot_dsts)

%% Setup
error(nargchk(4, 5, nargin));

if ~exist('b_plot_dsts', 'var') || isempty(b_plot_dsts)
	b_plot_dsts = false;
end

SS_MIN_DST = -50; % What DST has to dip below to be considered a substorm

epoch_win = [epoch_win_start epoch_win_end];
epoch_win_len = epoch_win_end - epoch_win_start;

%% Find substorms
[date, dst] = dst_read_datenum(start_date, end_date);

% dst = smooth(dst, 5);
% SMOOTH THE DATA OR NO?

low_dst_i = find(dst < SS_MIN_DST);

% Determine "substorm intervals" - contiguous intervals where DST <
% SS_MIN_DST
aa = (low_dst_i(2:end) - low_dst_i(1:end-1) == 1);
bb = find(aa == 0);
ss_int_i = zeros(2, length(bb)+1);

ss_int_i(1,1) = low_dst_i(1);
for kk = 1:length(bb-1)
	ss_int_i(2,kk) = low_dst_i(bb(kk));
	ss_int_i(1,kk+1) = low_dst_i(bb(kk)+1);
end
ss_int_i(2,end) = low_dst_i(end);

% Discard intervals that begin or end too close to the start or end date
% (12 hours)
mask = true(1, size(ss_int_i,2));
for kk = 1:size(ss_int_i,2)
	if ss_int_i(1,kk) < abs(epoch_win_start*24) || ss_int_i(2,kk) > length(date)-abs(epoch_win_end*24)
		mask(kk) = false;
	end
end
ss_int_i(:,~mask) = [];

% % Discard intervals that are less than two hours long
% mask = true(1, size(ss_int_i,2));
% for kk = 1:size(ss_int_i,2)
% 	if ss_int_i(1,kk) == ss_int_i(2,kk)
% 		mask(kk) = false;
% 	end
% end
% ss_int_i(:,mask) = [];

% Find minimum DST in each substorm interval
ss_min_i = zeros(1,size(ss_int_i,2));
ss_min_date = zeros(1,size(ss_int_i,2));
ss_min_dst = zeros(1,size(ss_int_i,2));
for kk = 1:length(ss_min_i)
	ss_min_i(kk) = find(dst(ss_int_i(1,kk):ss_int_i(2,kk)) == min(dst(ss_int_i(1,kk):ss_int_i(2,kk))), 1) + ss_int_i(1,kk) - 1;
	ss_min_date(kk) = date(ss_min_i(kk));
	ss_min_dst(kk) = dst(ss_min_i(kk));
end

%% Create superposed DST plot
if b_plot_dsts
	superposed_dsts = zeros(length(ss_min_i), epoch_win_len*24+1);
	for kk = 1:length(ss_min_i)
		superposed_dsts(kk,:) = dst((ss_min_i(kk)+24*epoch_win_start):(ss_min_i(kk)+24*epoch_win_end));
	end

	figure;
	hold on; grid on;

	% Plot st. dev.
	upper_std = zeros(1, epoch_win_len*24+1);
	lower_std = zeros(1, epoch_win_len*24+1);
	for kk = 1:(epoch_win_len*24+1)
		this_superposed_dsts = superposed_dsts(:,kk);
		upper_std(kk) = std(this_superposed_dsts(this_superposed_dsts > mean(this_superposed_dsts)));
		lower_std(kk) = std(this_superposed_dsts(this_superposed_dsts < mean(this_superposed_dsts)));
	end

	f = fill([(24*epoch_win_start:24*epoch_win_end) (24*epoch_win_end:-1:24*epoch_win_start)]/24, ...
		[mean(superposed_dsts) - lower_std, fliplr(mean(superposed_dsts) + upper_std)], ...
		[0.9 0.9 0.9], 'facealpha', 0.3, 'linewidth', 2);

	% Plot mean
	plot((24*epoch_win_start:24*epoch_win_end)/24, mean(superposed_dsts), 'LineWidth', 2);

	xlim(epoch_win);

	xlabel('Day from epoch');
	ylabel('DST (nT)');

	increase_font(gcf, 16);
end
