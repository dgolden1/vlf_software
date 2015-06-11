function emstat_hist_kp_occur(dates, normalize_oc_rate)

[kp_date, kp] = kp_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/kp/kp_2003.txt');
kpi = interp1(kp_date, kp, dates);

bins = [0:8 inf];
n = histc(kpi, bins);
if normalize_oc_rate, n = n/sum(n)*100; end
bar(0.5:8.5, n(1:9), 'hist');

xlabel('Kp');
if normalize_oc_rate
	ylabel('Normalized occurrence rate (percent of events)');
else
	ylabel('Ocurrence rate (number of events)');
end
