function plotEres_v_f_2d
% Plot Landau and 1st order cyclotron resonant energies for parallel
% propagation and loss cone electrons as a function of L and fraction of
% equatorial gyrofrequency

% By Daniel Golden (dgolden1 at stanford dot edu) January 2011
% $Id$

% close all;
clear;

addpath(fullfile(danmatlabroot, 'vlf', 'resonant_energies'));

%% CA92 density
mlt = 6;
kp = 5;
L = linspace(1.5, 7, 100);
ne = ca92(mlt, kp, L); % Carpenter and anderson 92 model

f_vec = linspace(0.1, 0.5, 20);

%% Determine resonant energies
Eres_landau = nan(length(f_vec), length(L));
Eres_cyclotron_pos = nan(length(f_vec), length(L));
Eres_cyclotron_neg = nan(length(f_vec), length(L));
w = nan(length(f_vec), length(L)); % angular wave frequency

for kk = 1:length(f_vec)
  [Eres_landau(kk,:), w(kk,:)] = calcEres_LC(L, 0, f_vec(kk), ne, 0);
  Eres_cyclotron_pos(kk,:) = calcEres_LC(L, 0, f_vec(kk), ne, 1);
  Eres_cyclotron_neg(kk,:) = calcEres_LC(L, 0, f_vec(kk), ne, -1);
end

Eres_landau(imag(Eres_landau) ~= 0) = nan;
Eres_cyclotron_pos(imag(Eres_cyclotron_pos) ~= 0) = nan;
Eres_cyclotron_neg(imag(Eres_cyclotron_neg) ~= 0) = nan;


%% Plot density and frequency
figure;

subplot(5, 1, 1);
plot( L, ne, 'LineWidth', 2 );
set(gca, 'Yscale', 'log', 'xticklabel', []);
grid on;
ylabel('Ne (cm^{-3})');
% title('CA92 Cold Plasma Density');
xlim([2 6]);

subplot(5, 1, 2);
imagesc(L, f_vec, log10(w/(2*pi)));
axis xy;
c = colorbar;
ylabel(c, 'Wave frequency (log_{10}(Hz))');

%% Plot resonant energies
subplot(5, 1, 3);
imagesc(L, f_vec, log10(Eres_landau*1e3));
axis xy;
c = colorbar;
ylabel(c, 'Landau resonance (log_{10}(eV))');

subplot(5, 1, 4);
imagesc(L, f_vec, log10(Eres_cyclotron_pos*1e3));
axis xy;
c = colorbar;
ylabel(c, '+1 Cyclotron resonance (log_{10}(eV))');

subplot(5, 1, 5);
imagesc(L, f_vec, log10(Eres_cyclotron_neg*1e3));
axis xy;
c = colorbar;
ylabel(c, '-1 Cyclotron resonance (log_{10}(eV))');

xlabel('Radial extent (R_E)');
