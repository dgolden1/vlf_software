close all;
clear;

load demosig.mat
fs = 25000;
demosig = demosig(1:fs*5);
figure(1)
plot_spectrogram(demosig,fs,3000,2048)

imp_locs = find_impulse_locs(demosig,30,10);
outsig = remove_impulses(demosig,imp_locs,100,100,30);
% imp_locs = find_impulse_locs(outsig,30,8);
% outsig = remove_impulses(outsig,imp_locs,100,100,30);

figure(2)
plot_spectrogram(outsig,fs,3000,2048)
figure(3)
ax(1) =subplot(2,1,1);
plot(demosig(fs*1.15:fs*1.2))
ax(2) =subplot(2,1,2);
plot(outsig(fs*1.15:fs*1.2))
linkaxes(ax,'xy');
