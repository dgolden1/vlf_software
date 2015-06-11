function h = plot_cum_spec_occur_prob(events, em_type)
% h = plot_cum_spec(events, em_type)
% Plot a "cumulative spectrogram" view of events
% Events are represented as overlapping semi-translucent boxes

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

%% Setup
error(nargchk(nargin, 2, 2));

% T_LOW = 5/60/24;
% T_HIGH = (23 + 59/60)/24;
T_LOW = 0;
T_HIGH = 1;

F_LOW = 0.3;
F_HIGH = 10;

n_t = 200; % Number of time points
n_f = 200; % Number of frequency points

%% Do the plotting

cum_spec = zeros(n_f, n_t);
t = linspace(T_LOW, T_HIGH, n_t);
f = linspace(F_LOW, F_HIGH, n_f).'; % kHz

[T, F] = meshgrid(t, f);

for kk = 1:length(events)
	mask = zeros(size(cum_spec));
	
	mask(T >= fpart(events(kk).start_datenum) & T <= fpart(events(kk).end_datenum) & ...
		F >= events(kk).f_lc & F <= events(kk).f_uc) = 1;
	
	cum_spec = cum_spec + mask;
end

%% Normalize by number of days of data
num_data_days = datenum([2003 11 01 0 0 0]) - datenum([2003 01 01 0 0 0]);
cum_spec = cum_spec/num_data_days*100;

imagesc(t, f, cum_spec);
axis xy;
xlim([0, 1]);
ylim([F_LOW F_HIGH]);

xlabel('Hour (Palmer LT)');
ylabel('Frequency (kHz)');

caxis([0 40]);

c = colorbar;
set(get(c, 'ylabel'), 'string', 'Percent of days seeing event');

%% Play with axes
grid on;

datetick('x', 'HH:MM', 'keeplimits');
set(gca, 'tickdir', 'out');
