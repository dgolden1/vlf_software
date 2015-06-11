function plot_wave_injection_geometry(L, wn_angle, gnd_type, bShowLegend, bShowTLabels)

%% Setup

if ~exist('bShowLegend', 'var') || isempty(bShowLegend), bShowLegend = true; end
if ~exist('bShowTLabels', 'var') || isempty(bShowTLabels), bShowTLabels = true; end

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

if bShowTLabels
	h1 = mmpolar(-thB*[1 1] + pi, [0 1], 'k', 'RTickVisible', 'off', 'RTickLabelVisible', 'off', 'TZeroDirection', 'South');
	hold on;
	h = mmpolar(-(thB + wn_angle)*[1 1], [0 1], 'b', 'RTickVisible', 'off', 'RTickLabelVisible', 'off', 'TZeroDirection', 'South');
else
	h1 = mmpolar(-thB*[1 1] + pi, [0 1], 'k', 'RTickVisible', 'off', 'RTickLabelVisible', 'off', 'TZeroDirection', 'South', 'TTickLabelVisible', 'off');
	hold on;
	h = mmpolar(-(thB + wn_angle)*[1 1], [0 1], 'b', 'RTickVisible', 'off', 'RTickLabelVisible', 'off', 'TZeroDirection', 'South', 'TTickLabelVisible', 'off');
end
set(h, 'LineWidth', 4);

title('''k''=B-field, ''b''=wn-angle');

if bShowLegend
	legend(h, 'B-field direction', 'Wavenormal direction', 'Location', 'NorthWest');
end
