function add_fh_lines_to_spec(h_ax)
% Add lines showing the L shells of 1/2 fHeq based on a dipole model of the
% Earth's magnetic field

% Formulas from Park (1972), p 88

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$


%% Setup
error(nargchk(1, 1, nargin));

r_o = 6370e3;

%% Calculate fHeq
L = 3:0.5:7;
r_eq = r_o*L;

fHeq = 8.736e5*(r_o./r_eq).^3;

fHeq = fHeq / 1e3; % Convert from Hz to kHz

%% Plot lines on spectrogram
axes(h_ax);
hold on;
y_lim = ylim;
y_max = y_lim(2);

x_lim = xlim;
x_min = x_lim(1);
x_max = x_lim(2);

for kk = 1:length(L)
	% if this 1/2 gyro frequency is in range of the plot limits, plot it
	if fHeq(kk)/2 <= y_max
		plot(x_lim, fHeq(kk)/2*[1 1]-0.05, 'w--');
		linelabel = sprintf('(1/2)fHeq = %0.1f kHz, L = %0.1f', fHeq(kk)/2, L(kk));
		text((x_max - x_min)*0.5 + x_min, fHeq(kk)/2, linelabel, 'Color', 'w', ...
			'FontWeight', 'bold', 'HorizontalAlignment', 'center');
	end
end
