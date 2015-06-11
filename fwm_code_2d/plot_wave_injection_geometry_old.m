function plot_wave_injection_geometry(L, wn_angle, gnd_type)

%% Setup

color_ice = [0.8 0.8 1];
color_seawater = [0.3 0.3 1];
color_conductor = [0.7 0.7 0.7];

switch gnd_type
	case 'ice'
		gnd_color = color_ice;
	case 'seawater'
		gnd_color = color_seawater;
	case 'conductor'
		gnd_color = color_conductor;
end


inv_lat = acos(sqrt(1/L));
thB = pi/2 - atan(2*tan(inv_lat));

n = 50;
x = linspace(-1, 1, n);

%% Plot ground, B field and wavenormal
figure;
hold on;

fill(x([1 end end 1]), 10*[0 0 -1 -1]); % ground
plot(x, zeros(1, n), 'k', 'LineWidth', 2);

plot(x, 120*ones(1, n), 'k', 'LineWidth', 2); % Ionosphere top

% B-field dir

