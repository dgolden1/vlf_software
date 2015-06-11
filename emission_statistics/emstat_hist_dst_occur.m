function emstat_hist_dst_occur(dates, normalize_oc_rate)

[dst_date, dst] = dst_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/dst/dst_2003.txt');
dsti = interp1(dst_date, dst, dates);

lowest_bin = -50;
highest_bin = 0;
bin_interval = 10;
bins = [-Inf lowest_bin:bin_interval:highest_bin Inf];
n = histc(dsti, bins);
if normalize_oc_rate, n = n/sum(n)*100; end
bar(lowest_bin-(bin_interval/2):bin_interval:(highest_bin+(bin_interval/2)), n(1:end-1), 'hist');
set(gca, 'XTick', (lowest_bin-bin_interval):bin_interval:(highest_bin+bin_interval));

XTickLabel = get(gca, 'XTickLabel');
XTickLabel = mat2cell(XTickLabel, ones(1, size(XTickLabel, 1)), size(XTickLabel, 2));
XTickLabel{1} = '-Inf';
XTickLabel{end} = 'Inf';
set(gca, 'XTickLabel', XTickLabel);

xlabel('Dst (nT)');
if normalize_oc_rate
	ylabel('Occurrence rate (percent of events)');
else
	ylabel('Ocurrence rate (number of events)');
end
