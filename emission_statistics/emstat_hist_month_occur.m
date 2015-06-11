function emstat_hist_month_occur(these_events, synoptic_epochs, em_type, ax)
% Plot histogram of emission occurrence, by month

% By Daniel Golden (dgolden1 at stanford dot edu) July 2008
% $Id$

%% Setup
b_overlay_ae_kp = true;

%% Make histograms

start_datenums = [these_events.start_datenum].';

% Total synoptic epochs
[n_total, mm_total] = get_hist(synoptic_epochs);


if strcmp(em_type, 'all')
  b_chorus = strcmp({these_events.type}, 'chorus');
  b_hiss = strcmp({these_events.type}, 'hiss');

  n_ch = get_hist(start_datenums(b_chorus));
  n_hi = get_hist(start_datenums(b_hiss));
  
  n_ch_norm = n_ch./n_total*96; % Units of events/day
  n_hi_norm = n_hi./n_total*96;
  
else
  % Emissions
  n = get_hist(start_datenums);

  % Normalize
  n_norm = n./n_total;
end

% Month names
month_doys = datenum([2001*ones(13, 1) (1:13).' ones(13, 1) zeros(13, 3)]).' - datenum([2001 0 0 0 0 0]);
month_names = datestr(datenum([2001 0 0 0 0 0]) + month_doys(1:end-1), 'mmm');
month_names = mat2cell(month_names, ones(12, 1), 3);
for kk = 2:2:length(month_names)
  month_names{kk} = '';
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
  b = bar((1:12).', [n_ch_norm.', n_hi_norm.'], 1);
  set(b(1), 'facecolor', 0.2*[1 1 1]);
  set(b(2), 'facecolor', 0.8*[1 1 1]);
  legend('Chorus', 'Hiss', 'Location', 'NorthEast');
  
  % classy error bars
  [m_ch, p_ch] = agresti_coull(n_total, n_ch, 0.05);
  [m_hi, p_hi] = agresti_coull(n_total, n_hi, 0.05);
   m_ch = m_ch*96; p_ch = p_ch*96; m_hi = m_hi*96; p_hi = p_hi*96; % Units of events/day

  hold on;
  for kk = 1:12
    plot(kk*[1 1] - 0.15, m_ch(kk) - p_ch(kk)*[0 1], 'linewidth', 2, 'color', 'w'); % White against dark bar
    plot(kk*[1 1] - 0.15, m_ch(kk) + p_ch(kk)*[0 1], 'linewidth', 2, 'color', 'k');
    plot(kk*[1 1] + 0.15, m_hi(kk) - p_hi(kk)*[0 1], 'linewidth', 2, 'color', 'k');
    plot(kk*[1 1] + 0.15, m_hi(kk) + p_hi(kk)*[0 1], 'linewidth', 2, 'color', 'k');
  end
else
  b = bar(1:12, n_norm, 1);
end
  

set(gca, 'XTick', 1:12, 'xticklabel', month_names);
grid on;
xlim([0.5 12.5]);

xlabel('Month');
ylabel('Emissions per day');
title(sprintf('%s norm. occur. (%d events, %s to %s)', em_type, ...
	length(these_events), datestr(floor(min(start_datenums))), datestr(ceil(max(start_datenums)))));

if myfig
  increase_font;
  figure_grow(gcf, 1.4, 1/1.4);
end

%% Overlay Kp and AE
if b_overlay_ae_kp
  [ae_date, ae] = ae_read_datenum;
  [kp_date, kp] = kp_read_datenum;
  
  kp = interp1(kp_date, kp, synoptic_epochs);
  ae = interp1(ae_date, ae, synoptic_epochs);
  
  ae_by_month = zeros(12, 1);
  kp_by_month = zeros(12, 1);
  
  for kk = 1:12
    ae_by_month(kk) = mean(ae(mm_total == kk));
    kp_by_month(kk) = mean(kp(mm_total == kk));
  end
  
  if exist('ax', 'var') && length(ax) == 2
    myfig2 = false;
    saxes(ax(2));
  else
    myfig2 = true;
    figure;
  end

  [ax, h1, h2] = plotyy(1:12, kp_by_month, 1:12, ae_by_month);
  set(get(ax(1), 'ylabel'), 'string', 'Avg Kp');
  set(get(ax(2), 'ylabel'), 'string', 'Avg AE (nT)');
  set(ax, 'xlim', [1 12]);
  xlabel('Month');
  set(ax, 'XTick', 1:12, 'xticklabel', month_names, 'xlim', [0.5 12.5]);
  set([h1 h2], 'linewidth', 2);
  set(h1, 'marker', '^', 'markerfacecolor', 'b');
  set(h2, 'marker', 's', 'markerfacecolor', [0 0.5 0]);
  set(ax(2), 'xticklabel', {});
  grid on;
  
  legend([h1 h2], 'Kp', 'AE', 'Location', 'NorthEast');
  
  if myfig2
    increase_font;
    figure_grow(gcf, 1.4, 1/1.4);
  end
end

function [n, mm] = get_hist(datenums)
[~, mm] = datevec(datenums);
n = hist(mm, 1:12);
