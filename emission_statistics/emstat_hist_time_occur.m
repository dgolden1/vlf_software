function emstat_hist_time_occur(these_events, synoptic_epochs, em_type, normalize_oc_rate, plot_type)

% $Id$

if ~exist('plot_type', 'var') || isempty(plot_type)
	plot_type = 'cartesian';
end

PALMER_MLT = -(4+1/60)/24;

event_times = [these_events.start_datenum];

% Create an "integrated times" vector, which has multiple
% points for each event, spanning the time of occurrence
bin_edges = (0:24)/24;
bin_centers = (0.5:1:23.5)/24;

n_events = histc(fpart(event_times + PALMER_MLT), bin_edges);
n_events = n_events(1:end-1); % Remove the h=24 bin

% Number of events in this hour divided by number of synoptic epochs in
% this hour
n_total = histc(fpart(synoptic_epochs + PALMER_MLT), bin_edges)/4;
n_total = n_total(1:end-1); % Remove the h=24 bin

figure;

switch plot_type
	case 'cartesian'
		if strcmp(normalize_oc_rate, 'to_events')
			bar(bin_centers, n_events/sum(n_events)*100, 1);
		elseif strcmp(normalize_oc_rate, 'to_days')

			% Divide number of days with event at this synoptic interval by number
			% of days of data without data gaps during this synoptic interval
			b = bar(bin_centers, n_events./n_total, 1);
		else
			b = bar(bin_centers, n_events, 1);
		end

		datetick('x', 'keeplimits');
		xlabel('Palmer LT');
		grid on;

		if strcmp(normalize_oc_rate, 'to_events')
			ylabel('Normalized occurrence rate (percent of events)');
		elseif strcmp(normalize_oc_rate, 'to_days')
			ylabel('Normalized occurrence rate');
		else
			ylabel('Ocurrence rate (number of events)');
		end

		figure_squish(gcf, 0.6, 1);
	case 'polar'
		switch normalize_oc_rate
			case 'to_events'
				polarbar(bin_centers*2*pi, num_events/length(these_events)*100);
			case 'to_days'
				polarbar(bin_centers*2*pi, n_events./n_total);
			otherwise
				polarbar(bin_centers*2*pi, num_events);
		end
	otherwise
		error('Invalid plot_type (%s)', plot_type);
end

title(sprintf('%s norm. occur. by MLT (%s to %s)', em_type, ...
	datestr(floor(min(event_times))), datestr(ceil(max(event_times)))));

increase_font(gcf);
