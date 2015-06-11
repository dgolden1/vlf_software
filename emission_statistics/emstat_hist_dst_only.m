function emstat_hist_dst_only(normalize_oc_rate)

[dst_date, dst] = dst_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/dst/dst_2003.txt');

lowest_bin = -100;
highest_bin = 50;
bin_interval = 25;
bins = [-Inf lowest_bin:bin_interval:(highest_bin-bin_interval) Inf];
n = histc(dst, bins);
if normalize_oc_rate, n = n/sum(n)*100; end
b = bar(lowest_bin-(bin_interval/2):bin_interval:(highest_bin-(bin_interval/2)), n(1:end-1), 'hist');
set(b, 'FaceColor', 'r');
set(gca, 'XTick', (lowest_bin-bin_interval):bin_interval:highest_bin);

XTickLabel = get(gca, 'XTickLabel');
XTickLabel = mat2cell(XTickLabel, ones(1, size(XTickLabel, 1)), size(XTickLabel, 2));
XTickLabel{1} = '-Inf';
XTickLabel{end} = 'Inf';
set(gca, 'XTickLabel', XTickLabel);

title(sprintf('DST statistics 2003'));
xlabel('DST (nT)');
if normalize_oc_rate
	ylabel('Normalized occurrence rate (percent of events)');
else
	ylabel('Ocurrence rate (number of events)');
end
