function emstat_hist_kp_only(normalize_oc_rate)

[kp_date, kp] = kp_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/kp/kp_2003.txt');

bins = [0:8 inf];
n = histc(kp, bins);
if normalize_oc_rate, n = n/sum(n)*100; end
b = bar(0.5:8.5, n(1:9), 'hist');
set(b, 'FaceColor', 'r');

% hist(kp);
title(sprintf('Kp statistics 2003'));
xlabel('Kp');
if normalize_oc_rate
	ylabel('Normalized occurrence rate (percent of events)');
else
	ylabel('Ocurrence rate (number of events)');
end
