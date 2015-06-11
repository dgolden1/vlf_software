function plot_hist_radial_occur(these_events, normalize_oc_rate)
% plot_hist_radial_occur(these_events, normalize_oc_rate)
% Plot a time-of-day style plot, but in a circular band
% centered around Palmer's L-shell

% By Daniel Golden (dgolden1 at stanford dot edu) July 2008
% $Id$

%% Setup
error(nargchk(2, 2, nargin));

L_MIN = 2.2;
L_MAX = 2.7;

%% Generate histogram information
% Create an "integrated times" vector, which has multiple
% points for each event, spanning the time of occurrence
num_pts = 50;
% time_pts = [0:num_pts-1]/num_pts;
time_pts = linspace(0, 1, num_pts);
delta = time_pts(2) - time_pts(1);
num_events = zeros(size(time_pts));
for kk = 1:length(time_pts)
	num_events(kk) = count_events_at_time(time_pts(kk) - delta/2, time_pts(kk) + delta/2, these_events);
end

switch normalize_oc_rate
	case 'to_events'
		num_events = num_events/length(these_events)*100;
		color_label = 'Percent of events';
	case 'to_days'
		first_day_of_data = datenum([2003 01 01 0 0 0]);
		last_day_of_data = datenum([2003 11 01 0 0 0]);
		days_of_data = last_day_of_data - first_day_of_data;
		num_events = num_events/days_of_data*100;
		color_label = 'Percent of days seeing event';
	otherwise
		color_label = 'Occurrence rate (number of events)';
end

%% Transform
theta = time_pts*2*pi - pi/2;
% theta = time_pts*2*pi;
r = [L_MIN L_MAX];

[Theta, R] = meshgrid(theta, r);

X = R.*cos(Theta);
Y = R.*sin(Theta);


%% Plot
values = repmat(num_events, 2, 1);
plot_radial_local_time(theta, X, Y, values, color_label, L_MIN, L_MAX);
