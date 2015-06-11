function calc_euv_angle_error

% Program to calculate error in using oblique geometries and and minimum-L
% estimations using the IMAGE EUV instrument in estimating the plasmapause
% position

% By Daniel Golden (dgolden1 at stanford dot edu) Jan 2009
% Based on code by Maria Spasojevic
% $Id$

% SM Coordinate system:
% Z: parallel to north magnetic pole (northern hemisphere)
% Y: perpendicular to Earth-sun line, towards dusk
% X: more-or-less, but not quite, towards sun (get from Y cross X)

%% Define initial satellite positions based on actual passes
XYZ = [-2.15 -0.29 3.57;  % Close (moving away from Earth)
	    4.05 -0.5  5.88;  % Medium (moving towards Earth)
		1.42  1.33 7.87]; % Far (apogee)
	
% Rotate satellite into the X-Z plane
xy = sqrt(sum((XYZ(:, 1:2).').^2));
XYZ(:,2) = 0;
XYZ(:,1) = xy;

XYZ0 = XYZ(1,:); % Do one IMAGE position at a time

% Get magnetic latitude and distance for IMAGE position
image_lat = atan(XYZ0(:,1)./XYZ0(:,3));
rho = sqrt(sum((XYZ0.').^2)); % Distance to Earth center

%% Get plasma density
[x, z, ne, L] = make_de_grid; % ne units are e/cm^3
[xx, zz] = meshgrid(x, z);


%% Upper left plot
% subplot(2, 2, 1);
% imagesc(x, z, log10(ne)); hold on;
% ne(~(ne > 0)) = nan;
% contour_levels = linspace(min(log10(ne(:))), max(log10(ne(:))), 20);
% contour(x, z, log10(ne), contour_levels, 'linecolor', 'k', 'linewidth', 1);
% grid on;
% axis xy
% xlabel('X (SM)');
% ylabel('Z (SM)');
% % c = colorbar;
% % set(get(c, 'ylabel'), 'string', 'log density (m^{-3})');
% 
% % Plot a white circle for the Earth
% tt = linspace(-pi/2, pi/2, 25);
% patch(cos(tt), sin(tt), 'w');

%% Left plot
figure;

subplot(1, 2, 1)
imagesc(x, z, log10(ne)); hold on;
ne(~(ne > 0)) = nan;
axis xy
xlabel('X (SM)');

ylabel('Z (SM)');
c = colorbar;
ylabel(c, 'electron density (log_{10} e/cm^3)');

% Plot a white circle for the Earth
tt = linspace(-pi/2, pi/2, 25);
patch(cos(tt), sin(tt), 'w');

set(gca, 'TickDir', 'out');
grid on;

title(sprintf('IMAGE FOV from XYZ_{SM} = [%0.1f, %0.1f, %0.1f] (R=%0.1f)', ...
	XYZ0(1), XYZ0(2), XYZ0(3), rho));


%% Generate rays from satellite
theta = linspace(-image_lat, pi/4, 50); % Angle measured from -z to +x with IMAGE at origin

% For each ray, get raypath and find integrated density
nr = 200; % num points along satellite ray
ray_r = linspace(0, 4 + XYZ0(3), nr); % Ray distances to calculate from IMAGE = 4 Re + IMAGE's Z value

ray_density = zeros(nr, length(theta));
ray_min_l = zeros(length(theta), 1);
ray_min_l_x = zeros(length(theta), 1);
ray_min_l_z = zeros(length(theta), 1);
for kk = 1:length(theta)
	
	ray_x = ray_r*sin(theta(kk)) + XYZ0(1); % Transform to cartesian coordinates centered at Earth
	ray_z = -ray_r*cos(theta(kk)) + XYZ0(3);
	
	mask = ray_z <= XYZ0(3);
	% Plot ray
	plot(ray_x(mask), ray_z(mask), 'k-');

	% Density along ray path, e/cm^3
	ray_density(:, kk) = interp2(xx, zz, ne, ray_x, ray_z);


	ray_l = interp2(xx, zz, L, ray_x, ray_z);
	[min_l, min_l_i] = min(ray_l);
	
	ray_min_l(kk) = min_l;
	ray_min_l_x(kk) = ray_x(min_l_i);
	ray_min_l_z(kk) = ray_z(min_l_i);
	if ray_min_l_x(kk).^2 + ray_min_l_z(kk).^2 < 1
		ray_min_l(kk) = nan; % If this ray intersects the earth, its minimum L is invalid
	else
		% Plot min L intersection points
		plot(ray_min_l_x(kk), ray_min_l_z(kk), 'ko', 'MarkerFaceColor', 'k', 'markersize', 3);
	end
end
ray_density(isnan(ray_density)) = 0;

% % Plot min L intersection points
% plot(ray_min_l_x, ray_min_l_z, 'ko', 'MarkerFaceColor', 'k', 'markersize', 3);

%% Make plot of integrated density vs. L-shell
int_density = sum(ray_density);
int_density(ray_min_l <= 1.2) = nan;

[min_l_sort, sort_i] = sort(ray_min_l);
int_density_sort = int_density(sort_i);

subplot(1, 2, 2);
semilogy(min_l_sort, int_density_sort, '.-', 'LineWidth', 2);
title(sprintf('Integrated column density'));
xlabel('Ray minimum L');
ylabel('Electron Density');
grid on;
hold on;

idx_valid = ~isnan(min_l_sort);
semilogy(min_l_sort(idx_valid), interp2(xx, zz, ne, min_l_sort(idx_valid), zeros(size(min_l_sort(idx_valid)))), 'r.-', 'LineWidth', 2);

legend('Norm column dens. (K*e/cm^2)', 'Eq. dens. (e/cm^3)', 'Location', 'NorthEast');
