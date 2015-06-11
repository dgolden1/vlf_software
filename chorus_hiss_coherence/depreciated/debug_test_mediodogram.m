% Plot mediograms for a bunch of data to get a feel for it

% $Id$

%% Setup
close all;
clear;

source_dir = '/media/amundsen/user_data/dgolden/temp/palmer_bb_cleaned/2001/03_19';
output_dir = '~/temp/burstiness/blah_03_19';

% Spectrogram
s_window = 512;
s_nfft = 512;
s_noverlap = 256;

% Mediodogram
m_window = 128;
m_nfft = 128;
m_noverlap = 64;

%% Run
d = dir(fullfile(source_dir, '*.mat'));

figure(1);
figure_grow(gcf, 1.5, 0.75);

for kk = 1:length(d)
  t_start = now;
  DF = load(fullfile(source_dir, d(kk).name));

  % Calibrate, create s_medodogram
  [data_cal, ~, cax] = palmer_cal_t(DF.data, DF.Fs, 2003);
  [~, f, T, P] = spectrogram_dan(data_cal, m_window, m_noverlap, m_nfft, DF.Fs);
  s_medodogram = 10*log10(median(P, 2));
  s_periodogram = 10*log10(mean(P, 2));

  clf;
  
  % Spectrogram
  s(1) = subplot(1, 4, [1 2]);
  [~, F_spec, T_spec, P_spec] = spectrogram_dan(data_cal, s_window, s_noverlap, s_nfft, DF.Fs);
  imagesc(T_spec, F_spec, 10*log10(P_spec));
  axis xy;
  caxis(cax);
  set(gca, 'ytick', 0:1000:8000);
  xlabel('sec');
  ylabel('Hz');
  title(strrep(d(kk).name, '_', '\_'));
  pos_spec = get(gca, 'position');
  
  % Mediodogram
  s(2) = subplot(1, 4, 3);
  plot(s_medodogram, f, s_periodogram, f, 'LineWidth', 2);
  grid on;
  set(gca, 'yticklabel', [], 'ytick', 0:1000:8000);
  legend('Median', 'Mean', 'Location', 'NorthEast');
  pos = get(gca, 'position');
  set(gca, 'position', [pos(1) pos_spec(2) pos(3) pos_spec(4)]);
  xlim(cax);
  xlabel('dB');
  title('Mediodogram');
  
  % Mediodogram slope
  s(3) = subplot(1, 4, 4);
  F_center = f(1:end-1) + diff(f)/2;
  plot(diff(s_medodogram)./diff(f)*1e3, F_center, 'LineWidth', 2);
  hold on;
  plot([0 0], F_center([1 end]), 'k', 'LineWidth', 2);
  grid on;
  set(gca, 'yticklabel', [], 'ytick', 0:1000:8000, 'xtick', -40:20:40);
  pos = get(gca, 'position');
  set(gca, 'position', [pos(1) pos_spec(2) pos(3) pos_spec(4)]);
  xlim([-50 50]);
  xlabel('dB/kHz');
  title('Mediodogram slope');
  
  linkaxes(s, 'y');
  ylim([0 8000]);
  
  [~, name] = fileparts(d(kk).name);
  print('-dpng', fullfile(output_dir, name));
  fprintf('Wrote %s (%d of %d) in %s\n', fullfile(output_dir, name), kk, length(d), time_elapsed(t_start, now));
end
