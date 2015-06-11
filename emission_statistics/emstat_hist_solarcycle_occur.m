function emstat_hist_solarcycle_occur(these_events, synoptic_epochs, em_type, ax)
% Plot histogram of emission occurrence, over the course of a solar cycle

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
b_overlay_ae_kp = true;

MIN_DAYS_PER_MONTH = 12;

%% Make bin edges on month edges
start_datenums = [these_events.start_datenum].';

[start_year, start_month] = datevec(min(start_datenums));
[end_year, end_month] = datevec(max(start_datenums));

years = start_year:end_year;
months = 1:12;

[Months, Years] = ndgrid(months, years);
month_datenums = datenum([Years(:), Months(:), ones(numel(Years), 1), zeros(numel(Years), 3)]);
mid_month_datenums = month_datenums(1:end-1) + diff(month_datenums)/2;

year_datenums = datenum([years.' ones(length(years), 2) zeros(length(years), 3)]);

%% Create histograms
n_total = get_hist(synoptic_epochs, month_datenums);
n_total = n_total/96; % Units of days

if strcmp(em_type, 'all')
  b_chorus = strcmp({these_events.type}, 'chorus');
  b_hiss = strcmp({these_events.type}, 'hiss');
  
  n_ch = get_hist(start_datenums(b_chorus), month_datenums);
  n_hi = get_hist(start_datenums(b_hiss), month_datenums);
  
  n_ch_norm = n_ch./n_total;
  n_hi_norm = n_hi./n_total;
  
  n_ch_norm(n_total < MIN_DAYS_PER_MONTH) = [];
  n_hi_norm(n_total < MIN_DAYS_PER_MONTH) = [];
  em_x = mid_month_datenums(n_total >= MIN_DAYS_PER_MONTH);
else
  n = get_hist(start_datenums, month_datenums);
  n_norm = n./n_total;
  
  n_norm(n_total < MIN_DAYS_PER_MONTH) = [];
  em_x = mid_month_datenums(n_total >= MIN_DAYS_PER_MONTH);
end

%% Plot
if exist('ax', 'var') && ~isempty(ax)
  myfig = false;
  saxes(ax(1));
else
  myfig = true;
  figure;
end


if strcmp(em_type, 'all')
  b = plot(em_x, n_ch_norm, '-v', em_x, n_hi_norm, '-o', 'linewidth', 2);
  set(b(1), 'color', 'r', 'markerfacecolor', 'r');
  set(b(2), 'color', [0.6 0 1], 'markerfacecolor', [0.6 0 1]);
else
  b = plot(em_x, n_norm, '-*', 'linewidth', 2);
end

set(gca, 'tag', 'emissions');

% set(gca, 'XTick', years, 'tickDir', 'out');
% xlim([years(1) - 0.5, years(end) + 0.5]);

datetick('x');
if strcmp(em_type, 'all')
  legend('Chorus', 'Hiss', 'Location', 'NorthEast');
end
xlim([datenum([start_year 1 1 0 0 0]), datenum([end_year+1 1 1 0 0 0])]);
grid on;

xlabel('Date');
ylabel('Emissions per day');
title(sprintf('%s norm. occur. over solar cycle (%d events, %s to %s)', em_type, ...
	length(these_events), datestr(floor(min(start_datenums))), datestr(ceil(max(start_datenums)))));

if myfig
  increase_font;
  figure_grow(gcf, 1.4, 1/1.4);
end

%% Kp and AE
if b_overlay_ae_kp
  [kp_date, kp] = kp_read_datenum;
  [ae_date, ae] = ae_read_datenum;
  kp = interp1(kp_date, kp, synoptic_epochs);
  ae = interp1(ae_date, ae, synoptic_epochs);

  kp_by_month = zeros(size(mid_month_datenums));
  ae_by_month = zeros(size(mid_month_datenums));
  for kk = 1:length(mid_month_datenums)
    this_idx = synoptic_epochs >= month_datenums(kk) & synoptic_epochs < month_datenums(kk+1);
    kp_by_month(kk) = mean(kp(this_idx));
    ae_by_month(kk) = mean(ae(this_idx));
  end
  kp_by_month(n_total == 0) = nan;
  ae_by_month(n_total == 0) = nan;

  if exist('ax', 'var') && length(ax) >= 2
    myfig2 = false;
    saxes(ax(2));
  else
    myfig2 = true;
    figure;
  end

  [axyy, h1, h2] = plotyy(mid_month_datenums, kp_by_month, mid_month_datenums, ae_by_month);
  set(axyy(1), 'tag', 'kp');
  set(axyy(2), 'tag', 'ae');
  set(get(axyy(1), 'ylabel'), 'string', 'Avg Kp');
  set(get(axyy(2), 'ylabel'), 'string', 'Avg AE (nT)');
  set([h1 h2], 'linewidth', 2);
  set(h1, 'marker', '^', 'markerfacecolor', 'b');
  set(h2, 'marker', 's', 'markerfacecolor', [0 0.5 0]);
  saxes(axyy(2)); datetick('x');
  set(axyy(1), 'xticklabel', {}, 'xtick', [], 'ylim', [0 5], 'ytick', 0:5);
  set(axyy(2), 'ylim', [0 500], 'ytick', 0:100:500);
%   set(axyy, 'XTick', years);
%   set(axyy(1), 'xtickLabel', xlabels);
  xlim([datenum([start_year 1 1 0 0 0]), datenum([end_year+1 1 1 0 0 0])]);
  xlabel('Date');
  grid on;
  
  legend([h1 h2], 'Kp', 'AE', 'Location', 'NorthEast');
  
  if myfig2
    increase_font;
    figure_grow(gcf, 1.4, 1/1.4);
  end
end

%% F10.7cm solar flux
% Data from http://www.esrl.noaa.gov/psd/data/climateindices/list/
if b_overlay_ae_kp
  load('solarflux107.mat', 'f107', 'f107_date');
  f107 = f107(f107_date >= min(start_datenums) & f107_date <= max(start_datenums));
  f107_date = f107_date(f107_date >= min(start_datenums) & f107_date <= max(start_datenums));
  
  if exist('ax', 'var') && length(ax) >= 3
    myfig3 = false;
    saxes(ax(3));
  else
    myfig3 = true;
    figure;
  end

  h = plot(f107_date, f107/10, 'ko-', f107_date, smooth(f107/10, 12));
  set(h(2), 'color', [1 0.5 0]); % Orange
  set(gca, 'tag', 'f107');
  
  set(h(1), 'markerfacecolor', 'k', 'markersize', 4);
  set(h, 'linewidth', 2);
  ylabel('10.7cm Radio Flux (sfu)');
  datetick('x');
  
  xlim([datenum([start_year 1 1 0 0 0]), datenum([end_year+1 1 1 0 0 0])]);
  xlabel('Date');
  grid on;
  
  legend('Monthly values', 'Smoothed');
  
  if myfig3
    increase_font;
    figure_grow(gcf, 1.4, 1/1.4);
  end
end

function n = get_hist(datenums, month_datenums)
n = histc(datenums, month_datenums);
n = n(1:end-1);
