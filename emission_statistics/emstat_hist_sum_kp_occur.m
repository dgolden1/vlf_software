function emstat_hist_sum_kp_occur(dates, normalize_oc_rate)

[kp_date, sum_kp] = gen_sum_kp;
kpi = interp1(kp_date, sum_kp, dates);

lowest_bin = 0;
highest_bin = 72;
bin_interval = 8;
bins = [-Inf lowest_bin:bin_interval:(highest_bin-bin_interval) Inf];
n = histc(kpi, bins);
if normalize_oc_rate, n = n/sum(n)*100; end
bar(lowest_bin-(bin_interval/2):bin_interval:(highest_bin-(bin_interval/2)), n(1:end-1), 'hist');
set(gca, 'XTick', (lowest_bin-bin_interval):bin_interval:highest_bin);

xlabel('\Sigma Kp');
if normalize_oc_rate
	ylabel('Normalized occurrence rate (percent of events)');
else
	ylabel('Ocurrence rate (number of events)');
end
