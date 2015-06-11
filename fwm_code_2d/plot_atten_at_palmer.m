% Plot results of collect_atten_at_palmer

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Setup
% close all;
clear;

%% Load and choose desired parameters
load('palmer_atten.mat');

% dep_var = 'f';
dep_var = 'L';
% dep_var = 'wn';

dep_var2 = 'f';
% dep_var2 = 'L';
% dep_var2 = 'wn';

f_target = 1000;
L_target = 5;
wn_target = 0; % degrees

if strcmp(dep_var, 'f') || strcmp(dep_var2, 'f'), f_target = []; end
if strcmp(dep_var, 'L') || strcmp(dep_var2, 'L'), L_target = []; end
if strcmp(dep_var, 'wn') || strcmp(dep_var2, 'wn'), wn_target = []; end


%% Parse out desired parameters
idx = ones(size(f_vec));

if ~isempty(f_target), idx = idx .* (f_vec == f_target); end
if ~isempty(L_target), idx = idx .* (L_vec == L_target); end
if ~isempty(wn_target), idx = idx .* (floor(wn_vec*180/pi) == wn_target); end
idx = logical(idx);

if strcmp(dep_var, 'f'), dep_vec = f_vec(idx); xlabelstr = 'f (kHz)'; end
if strcmp(dep_var, 'L'), dep_vec = L_vec(idx); xlabelstr = 'L'; end
if strcmp(dep_var, 'wn'), dep_vec = wn_vec(idx)*180/pi; xlabelstr = 'Wavenormal angle (degrees)'; end

if strcmp(dep_var2, 'f'), dep_vec2 = f_vec(idx); end
if strcmp(dep_var2, 'L'), dep_vec2 = L_vec(idx); end
if strcmp(dep_var2, 'wn'), dep_vec2 = wn_vec(idx)*180/pi; end


P_atten = P_palmer_vec(idx)./P_src_vec(idx);

%% 3-D correction factor
Re = 6371; % Earth's radius, km

P_atten = P_atten./(2*pi*palmer_dist_vec(idx)*1e3);

%% Plot
dep_vec2_unique = unique(dep_vec2);
figure;
hold on;
grid on;

P_atten_mat = zeros(length(dep_vec2_unique), length(unique(dep_vec)));
for kk = 1:length(dep_vec2_unique)
	this_idx = find(dep_vec2 == dep_vec2_unique(kk));
	P_atten_mat(kk, :) = P_atten(this_idx);
	legend_txt{kk} = sprintf('%s = %0.0f', dep_var2, dep_vec2_unique(kk));
end
dep_vec_unique = dep_vec(this_idx);

plot(dep_vec_unique, 10*log10(P_atten_mat), 'o', 'MarkerSize', 10);

%% Plot spline interpolation
x_int = linspace(max(dep_vec_unique), min(dep_vec));
P_atten_int_mat = zeros(length(dep_vec2_unique), length(x_int));
for kk = 1:length(dep_vec2_unique)
	P_atten_int_mat(kk, :) = interp1(dep_vec_unique, 10*log10(P_atten_mat(kk,:)), x_int, 'pchip');
end

h = plot(x_int, P_atten_int_mat, 'LineWidth', 2);
legend(h, legend_txt);

xlabel(xlabelstr);
ylabel('Attenuation from source to palmer');
titlestr = '';
if ~(strcmp(dep_var, 'f') || strcmp(dep_var2, 'f')), titlestr = [titlestr sprintf('f = %0.1f Hz, ', f_target/1e3)]; end
if ~(strcmp(dep_var, 'L') || strcmp(dep_var2, 'L')), titlestr = [titlestr sprintf('L = %0.2f, ', L_target)]; end
if ~(strcmp(dep_var, 'wn') || strcmp(dep_var2, 'wn')), titlestr = [titlestr sprintf('wn = %0.0f degrees, ', wn_target)]; end
titlestr(end-1:end) = [];
title(titlestr);

increase_font(gca);
