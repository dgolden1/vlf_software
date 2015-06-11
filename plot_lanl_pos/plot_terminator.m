function term_surf = plot_terminator(term_meridian)
% Plots the day-night terminator on a south-pole facing earth plot
% 
% INPUTS
% term_meridian: meridian (from 0 to 180) on which the terminator lies.
% Day is East (clockwise) of the specified meridian

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 16, 2007
% $Id$

% %% Format the meridian azimuth
% term_meridian = mod(term_meridian, 360);

%% Define colormap
night = [.8 .8 1];
day = [1 1 .6];

% colormap([night; day]);

a = linspace(night(1), day(1), 64).';
b = linspace(night(2), day(2), 64).';
c = linspace(night(3), day(3), 64).';
colormap([a b c]);

%% Create terminator
latv = linspace(-90, 0);
lonv = mod(linspace(term_meridian + 180, term_meridian), 360);
lonv = mod([lonv lonv+180], 360); % Second set of longitudes is for night
[lat, lon] = meshgrid(latv, lonv);

% terminator_mat = [ones(length(lat), length(lon)/2); zeros(length(lat), length(lon)/2)];

% terminator_mat = abs(mod(term_meridian - 90, 360) - mod(lon, 360));
terminator_mat = mod(abs(term_meridian - 90 - lon), 360);
ob_i = find(terminator_mat > 180); % Distances that have "overshot" 180
terminator_mat(ob_i) = 360 - terminator_mat(ob_i);

% Play with the values to make the colors nicer
terminator_mat = (terminator_mat - mean(terminator_mat(:)));
terminator_mat = abs(terminator_mat).^(0.75) .* sign(terminator_mat);

term_surf = surfm(lat, lon, terminator_mat);
