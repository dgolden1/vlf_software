function emstat_hist_year_occur(these_events, synoptic_epochs, em_type, ax)
% Plot histogram of emission occurrence, by year

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
b_overlay_ae_kp = true;

%% Create histograms
% Number of events per year
start_datenums = [these_events.start_datenum].';

[yy, ~] = datevec(start_datenums);
years = unique(yy);

% Number of synoptic epochs per day for a given year
[n_total, yy_total] = get_hist(synoptic_epochs, years);

if strcmp(em_type, 'all')
  b_chorus = strcmp({these_events.type}, 'chorus');
  b_hiss = strcmp({these_events.type}, 'hiss');
  
  n_ch = get_hist(start_datenums(b_chorus), years);
  n_hi = get_hist(start_datenums(b_hiss), years);
  
  n_ch_norm = n_ch./n_total*96; % Units of events per day
  n_hi_norm = n_hi./n_total*96;
else
  % Number of emissions per day for a given year
  n = get_hist(start_datenums, years);
  
  % Normalize
  n_norm = n./n_total;
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
  b = bar(years, [n_ch_norm.' n_hi_norm.'], 1);
  set(b(1), 'facecolor', 0.2*[1 1 1]);
  set(b(2), 'facecolor', 0.8*[1 1 1]);
  legend('Chorus', 'Hiss', 'Location', 'NorthEast');
  
  % classy error bars
  [m_ch, p_ch] = agresti_coull(n_total, n_ch, 0.05);
  [m_hi, p_hi] = agresti_coull(n_total, n_hi, 0.05);
  m_ch = m_ch*96; p_ch = p_ch*96; m_hi = m_hi*96; p_hi = p_hi*96; % Units of events/day

  hold on;
  for kk = 1:length(years)
    plot(years(kk)*[1 1] - 0.15, m_ch(kk) - p_ch(kk)*[0 1], 'linewidth', 2, 'color', 'w'); % White against dark bar
    plot(years(kk)*[1 1] - 0.15, m_ch(kk) + p_ch(kk)*[0 1], 'linewidth', 2, 'color', 'k');
    plot(years(kk)*[1 1] + 0.15, m_hi(kk) - p_hi(kk)*[0 1], 'linewidth', 2, 'color', 'k');
    plot(years(kk)*[1 1] + 0.15, m_hi(kk) + p_hi(kk)*[0 1], 'linewidth', 2, 'color', 'k');
  end
%   errorbar(years - 0.15, m_ch, p_ch, 'linestyle', 'none', 'color', 'k');
%   errorbar(years + 0.15, m_hi, p_hi, 'linestyle', 'none', 'color', 'k');
else
  b = bar(years, n_norm, 1);
end

xlabels = cellfun(@num2str, num2cell(years), 'uniformoutput', false);
for kk = 2:2:length(xlabels)
  xlabels{kk} = '';
end

set(gca, 'XTick', years, 'xtickLabel', xlabels);
xlim([years(1) - 0.5, years(end) + 0.5]);
grid on;

xlabel('Year');
ylabel('Emissions per day');
title(sprintf('%s emissions norm. occur. (%d events, %s to %s)', em_type, ...
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

  kp_by_year = zeros(size(years));
  ae_by_year = zeros(size(years));
  for kk = 1:length(years)
    kp_by_year(kk) = mean(kp(yy_total == years(kk)));
    ae_by_year(kk) = mean(ae(yy_total == years(kk)));
  end
  
  if exist('ax', 'var') && length(ax) == 2
    myfig2 = false;
    saxes(ax(2));
  else
    myfig2 = true;
    figure;
  end
  
  [ax, h1, h2] = plotyy(years, kp_by_year, years, ae_by_year);
  set(get(ax(1), 'ylabel'), 'string', 'Avg Kp');
  set(get(ax(2), 'ylabel'), 'string', 'Avg AE (nT)');
  set([h1 h2], 'linewidth', 2);
  set(h1, 'marker', '^', 'markerfacecolor', 'b');
  set(h2, 'marker', 's', 'markerfacecolor', [0 0.5 0]);
  set(ax, 'XTick', years);
  set(ax(1), 'xtickLabel', xlabels);
  set(ax(2), 'xticklabel', {});
  set(ax, 'xlim', [years(1) - 0.5, years(end) + 0.5]);
  xlabel('Year');
  grid on;
  
  legend([h1 h2], 'Kp', 'AE', 'Location', 'NorthEast');
  
  if myfig2
    increase_font;
    figure_grow(gcf, 1.4, 1/1.4);
  end
end

function [n, yy] = get_hist(datenums, years)
[yy, ~] = datevec(datenums);
numyears = length(years);
n = hist(yy, numyears);
