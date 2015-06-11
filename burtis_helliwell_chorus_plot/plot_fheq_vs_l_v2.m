function plot_fheq_vs_l_v2
% Function to plot 0.1 and 0.7 fHeq vs L
% In the spirit of Burtis and Helliwell 1976 figure 9 and Spasojevic 2005
% figure 2B
% Formulas from Park (1972), p 88

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% SETUP
F_NPTS = 200;
L_NPTS = 200;
f_max = 8; % kHz

%% Formulae
r_o = 6370e3;
L = linspace(2, 8, L_NPTS);
r_eq = r_o*L;
fHeq = 8.736e5*(r_o./r_eq).^3;
fHeq = fHeq / 1e3; % Convert from Hz to kHz

%% Load Burtis and Helliwell plot
load bhchorus.mat

%% Construct 3D plot across L-shells
p_img = zeros(F_NPTS, L_NPTS);
f = linspace(0, f_max + 2, F_NPTS);
for kk = 1:length(L)
	this_f = ffH*fHeq(kk);
	i = (this_f < f_max + 2);
	this_slice = interp1(this_f(i), p(i), f, 'spline');
	this_slice(this_slice < 0) = 0;
	this_slice(f > max(this_f(i))) = 0; % Get ride of crazy spline extrapolation
	
% 	plot(f, this_slice);
% 	xlabel('f');
% 	ylabel('percent');
% 	
	p_img(:, kk) = this_slice;
end
p_img(p_img < 0) = 0;

%% Plot
figure;
imagesc(L, f, p_img);
axis xy;
grid on;
ylim([0 f_max]);
xlabel('L-shell');
ylabel('Frequency (kHz)');
title('Expected chorus frequencies from Burtis and Helliwell (1976)');

% load('bhchorus_colormap.mat', 'bh_cmap');
% colormap(bh_cmap);
colormap(jet_with_white);
c = colorbar;
set(get(c, 'ylabel'), 'String', 'Percent observed');

increase_font(gcf, 16);
