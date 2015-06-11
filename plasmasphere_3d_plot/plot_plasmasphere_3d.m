function plot_plasmasphere_3d
% plot_plasmasphere_3d
% Make a plot of plasmaspheric density across a meridional plane using the
% Carpenter and Anderson 1992 model
% 
% It's not particularly accurate, but it will make a plot that looks like
% the prototypical plasmapause cartoon

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$


%% Setup
addpath('../resonant_energies');

R_MAX = 10;
NUM_R = 300;

%% Run Carpenter and Anderson model
mlt = 12;
kp = 3.5;

[ne_ca, L_ca] = ca92(mlt, kp);

%% Make the picture prettier by extending the model a little
ne_ca = [ne_ca(1) ne_ca];
L_ca = [1 L_ca];


%% Get model values on a R/theta grid
% From Park 1972, p88
% L = R/cos^2(phi)  with R in Earth radii

theta_vec = linspace(0, 2*pi, NUM_R+1);
R_vec = linspace(1, R_MAX, NUM_R);

density_mat = zeros(length(R_vec), length(theta_vec));

for kk = 1:length(theta_vec)
	theta = theta_vec(kk);
	% Calculate L-values for this theta
	L = R_vec/cos(theta)^2;
% 	ne = interp1(L_ca, ne_ca, L, 'linear', 'extrap');
	ne = interp1(L_ca, ne_ca, L, 'linear', 0);
	density_mat(:,kk) = ne;
end

density_mat(density_mat == 0) = NaN;

%% Transform to X-Y grid
[theta_mat, R_mat] = meshgrid(theta_vec, R_vec);
X = R_mat.*cos(theta_mat);
Y = R_mat.*sin(theta_mat);

%% Delete some values to make a prettier plot
% density_mat = density_mat(:);
% X = X(:);
% Y =Y(:);

% X(isnan(density_mat)) = [];
% Y(isnan(density_mat)) = [];
% density_mat(isnan(density_mat)) = [];

%% Plot it!
figure;
p = pcolor(X, Y, density_mat);
load jet_with_white;
colormap(jet_with_white);
set(p, 'linestyle', 'none');
xlabel('X_{SM} (R_E)');
ylabel('Z_{SM} (R_E)');
title(sprintf('Carpenter and Anderson Plasmasphere Model (Kp = %0.1f)', kp));
xlim([-5 5]);
ylim([-2 2]);
axis equal

hold on;

%% Add l-shell lines
%  Draw L-shell lines using Walt's equation of field line
for switchsides = [-1 1]
	for LShell = [2 3 4 5]
		LShellLine = [];
		EndTheta = acos(sqrt(1.0/LShell));
		for ii = -EndTheta:(2*pi/5000):EndTheta
			r = LShell*(cos(ii)^2) * switchsides;
			LShellLine = [LShellLine; r*cos(ii) r*sin(ii) ];
		end
		plot(LShellLine(:,1),LShellLine(:,2), 'LineWidth',2 ,'Color', 'k')
	end
end

increase_font(gcf, 16)
