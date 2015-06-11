function plot_substorm_distribution

%% Setup
start_date = datenum([2003 01 01 0 0 0]);
end_date = datenum([2003 11 01 0 0 0]);

% epoch_win_start = -2;
% epoch_win_end = 5;
epoch_win_start = 0;
epoch_win_end = 1;
epoch_length = epoch_win_end - epoch_win_start;

em_int = [3 9]; % Chorus emission interval

b_plot_dsts = false;

%% Get substorms and histogram of emission intervals
[ss_min_dst ss_min_date] = get_substorms(start_date, end_date, epoch_win_start, epoch_win_end, b_plot_dsts);
ss_min_date = utc_to_palmer_lt(ss_min_date);

% Create a vector of times in the chorus emission interval from the epoch
bins = 0:23;
n = histc(fpart(ss_min_date)*24, 0:24);
n = n(1:end-1);

n_em_int = zeros(size(bins));
em_int_vec = em_int(1):(em_int(2)-1);
for kk = 1:length(em_int_vec)
	n_em_int = n_em_int + circshift(n.', em_int_vec(kk)).';
end

%% Plot histogram
figure;
% bar(bins + 0.5, n_em_int, 'hist');
% xlim([0 24]);
% xlabel('Hour from epoch');
% ylabel('Samples in emission interval');
% increase_font

big_bins = zeros(1, length(bins)*epoch_length);
for kk = 1:(epoch_length)
	big_bins((kk-1)*length(bins)+1:kk*length(bins)) = (bins+0.5)/24 + (epoch_win_start + kk - 1);
end
bar(big_bins, repmat(n_em_int, 1, epoch_length), 'hist');
xlim([epoch_win_start epoch_win_end]);
xlabel('Days from epoch');
ylabel('Samples in emission interval');
increase_font

%% Scatter of dsts
figure;
scatter(fpart(ss_min_date)*24, ss_min_dst, 'filled');
grid on;
xlim([0 24]);
xlabel('Hour (Palmer LT)');
ylabel('DST (nT)');
increase_font
