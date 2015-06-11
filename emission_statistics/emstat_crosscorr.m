function emstat_crosscorr
% Find the cross-correlation between different types of emissions occurring
% in their emission intervals on the same day

% By Daniel Golden (dgolden1 at stanford dot edu) September 2008
% $Id$

%% Setup
% PALMER_LONGITUDE = -64.05;
% PALMER_T_OFFSET = PALMER_LONGITUDE/360;
PALMER_T_OFFSET = -(4+1/60)/24;

START_DATENUM = datenum([2003 01 01 0 0 0]);
END_DATENUM = datenum([2003 11 01 0 0 0]);

MAX_STAT_PTS = 100; % Don't calculate mean/std. beyond abs(delay) > MAX_STAT_PTS

XLIM = 10*[-1 1];
YLIM = [0.85 0.95];

% b_set_ylim = true;
b_set_ylim = false;
b_use_area_plot = false;
b_use_mask = false;


%% DEBUG: only load select values of AE
[idx_date, idx] = ae_read_datenum('/home/dgolden/vlf/case_studies/ae/ae_2003.txt');

idx = idx(idx_date >= START_DATENUM & idx_date < END_DATENUM);
idx_date = idx_date(idx_date >= START_DATENUM & idx_date < END_DATENUM);

% For each day, find maximum intensity of AE in that day
days = datenum(START_DATENUM:1:(END_DATENUM-1));
idxi = zeros(1, length(days));
for kk = 1:length(days)
	t_start = days(kk);
	t_end = days(kk) + 1;
	idxi(kk) = max(idx(idx_date >= t_start & idx_date <= t_end));
end

%% Load emissions
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');
events = combine_cross_day_events(events);
events = convert_from_utc_to_palmerlt(events);
events = split_cross_day_events(events);

n = length(events);

%% DEBUG: parse using AE
if b_use_mask
	AE_MIN = 1000;
	AE_MAX = AE_MIN+200;
	ok_days = days((idxi > AE_MIN) & (idxi < AE_MAX)); % Choose the value of AE to parse out
	mask = false(size(events));
	for kk = 1:length(events)
		if ~isempty(find(ok_days == floor(events(kk).start_datenum), 1))
			mask(kk) = true;
		end
	end
	events = events(mask);

	disp(sprintf('AE_MIN = %d, AE_MAX = %d, %d%% of days and %d%% of events remain', ...
		AE_MIN, AE_MAX, round(length(ok_days)/length(days)*100), round(length(events)/n*100)));
end

%% Parse emissions into different types
[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events);

dawn_int_start = datenum([0 0 0 03 0 0]);
dawn_int_end = datenum([0 0 0 09 0 0]);
dusk_int_start = datenum([0 0 0 14 0 0]);
dusk_int_end = datenum([0 0 0 23 0 0]);

chorus_days = find_event_days(chorus_events, days, dawn_int_start, dawn_int_end);
hiss_days = find_event_days(hiss_events, days, dusk_int_start, dusk_int_end);
chorus_with_hiss_days = find_event_days(chorus_with_hiss_events, days, dawn_int_start, dawn_int_end);

%% Emissions as predictors of themselves on a different day
figure;

subplot(3, 1, 1);
[c_cc, delays] = xorxcorr(chorus_days);
c_cc = c_cc(abs(delays) <= MAX_STAT_PTS);
delays = delays(abs(delays) <= MAX_STAT_PTS);
if b_use_area_plot
	area(delays, c_cc);
else
	plot_delays_line(c_cc, delays);
end
grid on;
xlim(XLIM);
if b_set_ylim
	ylim([0.5 1]);
end
title('Chorus days xcorr');

subplot(3, 1, 2);
[c_hh, delays] = xorxcorr(hiss_days);
c_hh = c_hh(abs(delays) <= MAX_STAT_PTS);
delays = delays(abs(delays) <= MAX_STAT_PTS);
if b_use_area_plot
	area(delays, c_hh);
else
	plot_delays_line(c_hh, delays);
end
grid on;
xlim(XLIM);
if b_set_ylim
	ylim([0.5 1]);
end
title('Hiss days xcorr');
set(gca, 'xticklabel', '');

subplot(3, 1, 3);
[c_ch, delays] = xorxcorr(chorus_with_hiss_days);
c_ch = c_ch(abs(delays) <= MAX_STAT_PTS);
delays = delays(abs(delays) <= MAX_STAT_PTS);
if b_use_area_plot
	area(delays, c_ch);
else
	plot_delays_line(c_ch, delays);
end
grid on;
xlim(XLIM);
if b_set_ylim
	ylim([0.5 1]);
end
title('Chorus with hiss days xcorr');
xlabel('Day offsets');

%% Emisssions as predictors of other emissions
minmin = 1;
maxmax = 0;
figure;

s(1) = subplot(3, 1, 1);
[c_c_h, delays] = xorxcorr(chorus_days, hiss_days);
c_c_h = c_c_h(abs(delays) <= MAX_STAT_PTS);
delays = delays(abs(delays) <= MAX_STAT_PTS);
minmin = min([minmin, min(c_c_h)]);
maxmax = max([maxmax, max(c_c_h)]);
if b_use_area_plot
	area(delays, c_c_h);
else
	plot_delays_line(c_c_h, delays);
end
grid on;
xlim(XLIM);
if b_set_ylim
	ylim(YLIM);
end
title('Chorus vs. hiss xcorr');
set(gca, 'xticklabel', '');

s(2) = subplot(3, 1, 2);
[c_c_ch, delays] = xorxcorr(chorus_days, chorus_with_hiss_days);
c_c_ch = c_c_ch(abs(delays) <= MAX_STAT_PTS);
delays = delays(abs(delays) <= MAX_STAT_PTS);
minmin = min([minmin, min(c_c_ch)]);
maxmax = max([maxmax, max(c_c_ch)]);
if b_use_area_plot
	area(delays, c_c_ch);
else
	plot_delays_line(c_c_ch, delays);
end
grid on;
xlim(XLIM);
if b_set_ylim
	ylim(YLIM);
end
title('Chorus vs. chorus with hiss xcorr');
set(gca, 'xticklabel', '');

s(3) = subplot(3, 1, 3);
[c_h_ch, delays] = xorxcorr(hiss_days, chorus_with_hiss_days);
c_h_ch = c_h_ch(abs(delays) <= MAX_STAT_PTS);
delays = delays(abs(delays) <= MAX_STAT_PTS);
minmin = min([minmin, min(c_h_ch)]);
maxmax = max([maxmax, max(c_h_ch)]);
if b_use_area_plot
	area(delays, c_h_ch);
else
	plot_delays_line(c_h_ch, delays);
end
grid on;
xlim(XLIM);
if b_set_ylim
	ylim(YLIM);
end
title('Hiss vs. chorus with hiss xcorr');
xlabel('Day offsets');

minmin = floor(minmin*20)/20;
maxmax = ceil(maxmax*20)/20;

for kk = 1:length(s)
	axes(s(kk));
	ylim([minmin maxmax]);
end

%% Create bar graphs for -1, 0 and +1 delays: emissions as predictors of themselves
figure;

subplot(3, 1, 1);
plot([-0.4 1.4], 100*sum(chorus_days)/length(days)*[1 1], 'r--'); % mean
hold on;

values = 100*c_cc([delays == 0 | delays == 1]);
bar([0, 1], values);
grid on
ylabel('Percent chance');
set(gca, 'xtick', [0 1], 'xticklabel', '');
% errorbar([-1, 0, 1], values, 100*(mean(c_cc) + 1.5*std(c_cc))*[1 1 1], 'Color', [0.8 0.0 0.0], 'LineStyle', 'none');
ylim([0 100]);
title('Chorus days xcorr');


subplot(3, 1, 2);
plot([-0.4 1.4], 100*sum(hiss_days)/length(days)*[1 1], 'r--'); % mean
hold on;

values = 100*c_hh([delays == 0 | delays == 1]);
bar([0, 1], values);
grid on
ylabel('Percent chance');
set(gca, 'xtick', [0 1], 'xticklabel', '');
% errorbar([-1, 0, 1], values, 100*(mean(c_hh) + 1.5*std(c_hh))*[1 1 1], 'Color', [0.8 0.0 0.0], 'LineStyle', 'none');
ylim([0 100]);
title('Hiss days xcorr');


subplot(3, 1, 3);
plot([-0.4 1.4], 100*sum(chorus_with_hiss_days)/length(days)*[1 1], 'r--'); % mean
hold on;

values = 100*c_ch([delays == 0 | delays == 1]);
bar([0, 1], values);
grid on
ylabel('Percent chance');
set(gca, 'xtick', [0 1], 'xticklabel', {'Same day', 'Following day'});
% errorbar([-1, 0, 1], values, 100*(mean(c_ch) + 1.5*std(c_ch))*[1 1 1], 'Color', [0.8 0.0 0.0], 'LineStyle', 'none');
ylim([0 100]);
title('Chorus with hiss days xcorr');

%% Create bar graphs for -1, 0 and +1 delays: emissions as predictors of others
figure;

subplot(3, 1, 1);
hold on;
plot([-1.5 1.5], 100*sum(chorus_days)/length(days)*[1 1], 'r--'); % mean of chorus
plot([-1.5 1.5], 100*sum(hiss_days)/length(days)*[1 1], 'g--'); % mean of hiss

values = 100*c_c_h([delays == -1 | delays == 0 | delays == 1]);
bar([-1, 0, 1], values);
grid on
ylabel('Percent chance');
set(gca, 'xtick', [-1 0 1], 'xticklabel', '');
% errorbar([-1, 0, 1], values, 100*(mean(c_c_h) + 1.5*std(c_c_h))*[1 1 1], 'Color', [0.8 0.0 0.0], 'LineStyle', 'none');
ylim([0 100]);
title('Chorus (a) vs. hiss (b)');

subplot(3, 1, 2);
hold on;
plot([-1.5 1.5], 100*sum(chorus_days)/length(days)*[1 1], 'r--'); % mean of chorus
plot([-1.5 1.5], 100*sum(chorus_with_hiss_days)/length(days)*[1 1], 'g--'); % mean of chorus with hiss

values = 100*c_c_ch([delays == -1 | delays == 0 | delays == 1]);
bar([-1, 0, 1], values);
grid on
ylabel('Percent chance');
set(gca, 'xtick', [-1 0 1], 'xticklabel', '');
% errorbar([-1, 0, 1], values, 100*(mean(c_c_ch) + 1.5*std(c_c_ch))*[1 1 1], 'Color', [0.8 0.0 0.0], 'LineStyle', 'none');
ylim([0 100]);
title('Chorus (a) vs. chorus with hiss (b)');

subplot(3, 1, 3);
hold on;
plot([-1.5 1.5], 100*sum(hiss_days)/length(days)*[1 1], 'r--'); % mean of hiss
plot([-1.5 1.5], 100*sum(chorus_with_hiss_days)/length(days)*[1 1], 'g--'); % mean of chorus with hiss

values = 100*c_h_ch([delays == -1 | delays == 0 | delays == 1]);
bar([-1, 0, 1], values);
grid on
ylabel('Percent chance');
set(gca, 'xtick', [-1 0 1], 'xticklabel', ...
	{sprintf('(a) preceding (b)'), sprintf('(a) same day as (b)'), sprintf('(a) succeeceding (b)')});
% errorbar([-1, 0, 1], values, 100*(mean(c_h_ch) + 1.5*std(c_h_ch))*[1 1 1], 'Color', [0.8 0.0 0.0], 'LineStyle', 'none');
ylim([0 100]);
title('Hiss (a) vs. chorus with hiss (b)');

function plot_delays_line(c, delays)

hold on;
mu = mean(c);
sigma = std(c);
fill(delays([1 end end 1]), mu + sigma*[-1 -1 1 1], [0.9 0.9 0.9], 'linestyle', 'none');
plot(delays([1 end]), [mu mu], 'r--');
plot(delays, c);
