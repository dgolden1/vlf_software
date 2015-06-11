function emstat_hist_sum_kp_only(normalize_oc_rate)

[kp_date, sum_kp] = gen_sum_kp;

lowest_bin = 0;
highest_bin = 72;
bin_interval = 8;
bins = [-Inf lowest_bin:bin_interval:(highest_bin-bin_interval) Inf];
n = histc(sum_kp, bins);
if normalize_oc_rate, n = n/sum(n)*100; end
b = bar(lowest_bin-(bin_interval/2):bin_interval:(highest_bin-(bin_interval/2)), n(1:end-1), 'hist');
set(b, 'FaceColor', 'r');

set(gca, 'XTick', (lowest_bin-bin_interval):bin_interval:highest_bin);

title('\Sigma Kp statistics 2003');
xlabel('\Sigma Kp');
if normalize_oc_rate
	ylabel('Normalized occurrence rate (percent of events)');
else
	ylabel('Ocurrence rate (number of events)');
end
