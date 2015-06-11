% function earth_ionosphere_waveguide_atten
% Using formulae from Inan and Inan pp264-

% By Daniel Golden (dgolden1 at stanford dot edu) October 2008
% $Id$

%% Invariants
palmer_lat = -64.77;
palmer_lon = -64.05;

%% Setup
f = linspace(100, 10e3, 100); % wave frequency, (Hz)
eta0 = 377; % impedance of free space, (ohms)
a = 85e3; % ionosphere height, (m)
sigma = 1e-6; % ionosphere conductivity, mean day/night, (Siemens/m)
eps0 = 8.854e-12; % Permittivity of free space (m^-3 kg^-1 s^4 A^2)
mu0 = 1.257e-6; % Permeability of free space (m kg / s^2 A^2)
m = [0:20]; % mode number
c = 1/sqrt(eps0*mu0); % speed of light in vacuum (m/s)
Re = 6371e3; % Earth radius (m)

%% Transform
[F, M] = meshgrid(f, m);

%% All modes
fc = M*c/(2*a); % [4.15]
Rs = sqrt(2*pi*F*mu0/(sigma)); % ~[4.22], use 1*sigma because we only have one lossy plate (ionosphere)

alpha_m = sqrt((M*pi/a).^2 - (2*pi*F).^2*mu0*eps0); % [4.17] - propagation losses
alpha_m = real(alpha_m);

%% TEM mode
alpha_c_tem = sqrt(2*pi*f*mu0/(2*sigma))/(eta0*a); % [4.22] - conducting losses

%% TE modes
alpha_c_te = 2*Rs.*(fc./F).^2./(eta0*a*sqrt(1 - (fc./F).^2)); % [4.23]
alpha_c_te(1,:) = Inf;

%% TM modes
alpha_c_tm = 2*Rs./(eta0*a*sqrt(1 - (fc./F).^2)); % [4.24]

%% Plot
alpha_te = real(alpha_m + alpha_c_te);
alpha_tm = real(alpha_m + alpha_c_tm);

figure;
plot(f/1e3, 10*log10(exp(2*alpha_tm(1:4, :)))*100e3, 'LineWidth', 2);
hold on;
plot(f/1e3, 10*log10(exp(2*alpha_te(1:4, :)))*100e3, '--', 'LineWidth', 2);
grid on;
xlabel('Frequency (kHz)');
ylabel('attenuation (dB/100 km)');
legend('tm_0', 'tm_1', 'tm_2', 'tm_3', 'te_0', 'te_1', 'te_2', 'te_3');
increase_font(gcf, 14);

% alpha_t = min([alpha_te; alpha_tm]);
alpha_t = alpha_tm(1,:);

figure;
plot(f/1e3, 10*log10(exp(2*alpha_t))*100e3, 'LineWidth', 2);
grid on;
xlabel('Frequency (kHz)');
ylabel('attenuation (dB/100 km)');
increase_font(gcf, 14);

%% Attenuation is minumum of mode attenuations
time_orig = linspace(-4.5, 4.5, 90); % Hours (wrt earth rotation)
time = abs(time_orig); % Hours (wrt earth rotation)

source_dist = 2000e3; % Directly south of Palmer
source_lat = palmer_lat - source_dist/(2*pi*Re)*360;
source_lon = palmer_lon + time_orig/24*360;

dist = deg2km(distance(palmer_lat, palmer_lon, source_lat, source_lon))*1e3; % Distance of source region, in m
% distance = 1000e3 + 2*pi*Re*cos(abs(palmer_lat*pi/180))*time/24; % Distance of source region, assuming it remains at Palmer's latitude

[Alpha_t, Distance] = meshgrid(alpha_t, dist);

Distance = Distance + 100e3*rand(size(Distance)); % Distributed source

% % Model spectrum for hiss
% spectrum = (f/100).^(-5);
% Spectrum = repmat(spectrum, length(time_orig), 1);

% power = exp(-2*Alpha_t.*Distance).*Spectrum;
power = exp(-2*Alpha_t.*Distance)./Distance;

figure;
imagesc(time_orig, f/1e3, 10*log10(power.'));
axis xy;
ylim([0.3 10]);
xlabel('Time (Hours from zenith)');
ylabel('Frequency (kHz)');
c = colorbar;
caxis([-300 -120]);
set(get(c, 'ylabel'), 'string', 'dB');
increase_font(gcf, 16);
