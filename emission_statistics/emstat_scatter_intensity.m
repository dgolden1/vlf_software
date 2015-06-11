function emstat_scatter_intensity(events)

em_types = {events.emission_type};
chorus_events = cellfun(@(x) ~isempty(findstr(x, 'chorus')), em_types);
hiss_events = cellfun(@(x) ~isempty(findstr(x, 'hiss')), em_types);

hold on;
scatter([events(chorus_events).start_datenum], [events(chorus_events).intensity], 'o');
scatter([events(hiss_events).start_datenum], [events(hiss_events).intensity], 'x');
legend('Chorus', 'Hiss');

grid on;

xlim([datenum([2003 01 01 0 0 0]) datenum([2004 01 01 0 0 0])]);
for kk = 1:13
	xticks(kk) = datenum([2003 (kk) 01 0 0 0]);
end
set(gca, 'XTick', xticks);
datetick('x', 'mmm', 'keepticks');
xlabel('Month');

ylabel('Intensity (uncal dB)');

title('Chorus and Hiss Intensities in 2003');
