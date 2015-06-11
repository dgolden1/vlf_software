function varargout = emstat_hist_freq_occur(em_type, these_events)
% [freq_edge_centers, occur_rate] = emstat_hist_freq_occur(em_type, these_events)

% freq_edges = 0:0.5:10; % kHz
freq_edges = linspace(0.3, 10, 30); % kHz
freq_edge_centers = freq_edges(1:end-1) + diff(freq_edges)/2;

% Count events in frequency bins
freq_counts = zeros(1, length(freq_edges)-1);
for kk = 1:length(freq_counts)
	freq_counts(kk) = count_events_at_freq(freq_edges(kk), freq_edges(kk+1), these_events);
end

occur_rate = freq_counts/length(these_events);

if nargout == 0
% 	bar(freq_edge_centers, occur_rate, 'hist');
	plot(freq_edge_centers, occur_rate, 'b', 'LineWidth', 2);

	xlabel('Frequency (kHz)');
	ylabel('Occurrence probability (per emission)');
% 	xlim([0.3 10]);
elseif nargout == 2
	varargout{1} = freq_edge_centers;
	varargout{2} = occur_rate;
else
	error('Weird number of output arguments');
end
