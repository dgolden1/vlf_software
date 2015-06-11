function plot_all_spectra

addpath(fullfile(danmatlabroot, 'vlf', '..', '..', 'vlftool_24_hour_fcn'));

figure;
hold on;

ssr = 100;


%% Hiss only
load hiss_spec
[em_psd, freq] = prepare_data(em_psd, freq);
[B_cal, unit_str] = cal_2003(sqrt(em_psd).', freq.', 512, 10e3);

% lhiss = plot(freq/1e3, B_cal, 'g', 'LineWidth', 3);
lhiss = plot(freq/1e3, B_cal, 'k', 'LineWidth', 3);
plot(freq(1:ssr:end)/1e3, B_cal(1:ssr:end), 'ks', 'MarkerFaceColor', 'w');

%% Chorus only
load chorus_only_spec
[em_psd, freq] = prepare_data(em_psd, freq);
[B_cal, unit_str] = cal_2003(sqrt(em_psd).', freq.', 512, 10e3);

% lchorus = plot(freq/1e3, B_cal, 'b', 'LineWidth', 3);
lchorus = plot(freq/1e3, B_cal, 'k', 'LineWidth', 3);
plot(freq(1:ssr:end)/1e3, B_cal(1:ssr:end), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 7);

%% Chorus with hiss
load chorus_with_hiss_spec
[em_psd, freq] = prepare_data(em_psd, freq);
[B_cal, unit_str] = cal_2003(sqrt(em_psd).', freq.', 512, 10e3);

% lchorushiss = plot(freq/1e3, B_cal, 'r', 'LineWidth', 3);
lchorushiss = plot(freq/1e3, B_cal, 'k', 'LineWidth', 3);
plot(freq(1:ssr:end)/1e3, B_cal(1:ssr:end), 'kd', 'MarkerFaceColor', 'w', 'MarkerSize', 8);


%% Misc
legend([lhiss lchorus lchorushiss], 'Hiss Only', 'Chorus Only', 'Chorus With Hiss');
grid on;
xlabel('Frequency (kHz)');
ylabel(unit_str);
increase_font(gcf, 16);

%% Function: prepare_data
function [em_psd, freq] = prepare_data(em_psd, freq)
em_psd = em_psd(freq >= 300);
freq = freq(freq >= 300);

em_psd = smooth(em_psd, 5).';
