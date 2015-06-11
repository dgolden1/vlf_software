function compare_themis_polar_chorus_ampl
% Compare THEMIS and Polar wave amplitudes that were measured near each
% other

% By Daniel Golden (dgolden1 at stanford dot edu) February 2011
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

%% Load Polar data
polar = load('/home/dgolden/vlf/case_studies/polar/PolarChorusDatabase_p.mat', 'Epoch', 'Xsm', 'Ysm', 'Zsm', 'Bw');

polar.r = sqrt(polar.Xsm.^2 + polar.Ysm.^2 + polar.Zsm.^2);
polar.L = polar.r./(1 - (polar.Zsm./polar.r).^2);
polar.lat = atan(polar.Zsm./sqrt(polar.Xsm.^2 + polar.Ysm.^2))*180/pi;
polar.MLT = mod(atan2(polar.Ysm, polar.Xsm)*24/(2*pi) + 12, 24);
polar.xyz_sm = [polar.Xsm; polar.Ysm; polar.Zsm];

% Only include certain measurements
idx_polar = polar.Bw > 0 & ... % Measurements with waves
            polar.lat < 25; % There's no THEMIS data above 25 deg

fn = fieldnames(polar);
for kk = 1:length(fn)
  polar.(fn{kk}) = polar.(fn{kk})(:, idx_polar).';
end

%% Load THEMIS data
[~, them] = get_combined_them_power('chorus');

% Only include certain measurements
idx_them = them.field_power > 0 & ... % with waves
           them.lat > 5 & ... % Above 4 degrees lat (there's no Polar below that for L > 5)
           sqrt(sum(them.xyz_sm(:,1:2).^2, 2)) < 6; % Within 6 Re in the X-Y plane (again, there's no overlap with Polar beyond that)
fn = fieldnames(them);
for kk = 1:length(fn)
  them.(fn{kk})(~idx_them, :) = [];
end


%% Find THEMIS measurements for each Polar measurement
% Nearest THEMIS index for each Polar point

% TriScatteredInterp speed test:
% n = 1e2: 0.015 sec
% n = 1e3: 0.071 sec
% n = 1e4: 1.2 sec
% n = 1e5: 6.7 sec
% n = 1e6: 65 sec (and it used up 10 GB of memory)
assert(size(them.xyz_sm, 1) < 1e5 & size(polar.xyz_sm, 1) < 1e5);
F = TriScatteredInterp(them.xyz_sm, (1:length(them.epoch)).', 'nearest');
nearest_them_idx = F(polar.xyz_sm);
% nearest_them_idx = griddatan(them.xyz_sm, (1:length(them.epoch)).', polar.xyz_sm, 'nearest');

% A given polar point must be this close, in Re, to its nearest THEMIS
% point in order to compare the two values
distance_thresh = 0.5;

distance_to_nearest_them_point = sqrt(sum((polar.xyz_sm - them.xyz_sm(nearest_them_idx, :)).^2, 2));
Ldiff_to_nearest_them_point = polar.L - them.L(nearest_them_idx);
MLTdiff_to_nearest_them_point = angledist(polar.MLT*2*pi/24, them.MLT(nearest_them_idx)*2*pi/24, 'rad', true)*24/2*pi;
latdiff_to_nearest_them_point = polar.lat - them.lat(nearest_them_idx);

% idx_valid = distance_to_nearest_them_point < distance_thresh;
idx_valid = Ldiff_to_nearest_them_point < 0.5 & abs(latdiff_to_nearest_them_point) < 5 & abs(MLTdiff_to_nearest_them_point) < 2;

nearest_them_ampl = sqrt(them.field_power(nearest_them_idx));

%% Plot amplitudes
polar_vals = log10(polar.Bw(idx_valid)); % log10 pT
them_vals = log10(nearest_them_ampl(idx_valid)) + 3; % log10 pT

figure;
scatter(polar_vals, them_vals);
xlabel('Polar ampl (pT)');
ylabel('THEMIS ampl (pT)');
increase_font;
grid on;
hold on;
axis equal

% Fit a straight line
b = [ones(size(them_vals)) them_vals]\polar_vals;
fit_x = quantile(polar_vals, [0 1]);
fit_y = quantile(them_vals, [0 1]);
plot(fit_x, [ones(size(fit_x)); fit_x].'*b, 'r', 'linewidth', 2);

1;
