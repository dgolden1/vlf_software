function plot_fheq_vs_l
% Function to plot 0.1 and 0.7 fHeq vs L
% In the spirit of Burtis and Helliwell 1976 figure 9 and Spasojevic 2005
% figure 2B
% Formulas from Park (1972), p 88

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% Formulae
r_o = 6370e3;
L = linspace(2, 6);
r_eq = r_o*L;
fHeq = 8.736e5*(r_o./r_eq).^3;
fHeq = fHeq / 1e3; % Convert from Hz to kHz

%% Plot
figure;
x = [L fliplr(L)];
y = [0.1*fHeq fliplr(0.7*fHeq)];
fill(x, y, [1 0.3 0.3]);
% plot(L, [0.1*fHeq; 0.7*fHeq], 'LineWidth', 2);
grid on;
ylim([0 10]);
xlabel('L shell');
ylabel('f (kHz)');
title('Expected chorus frequencies from Burtis and Helliwell (1976)');
increase_font(gcf, 16);

t1 = text(4.53, 7.04, '0.7 f_H_{eq}', 'FontSize', 16);
t2 = text(2.39, 2.84, '0.1 f_H_{eq}', 'FontSize', 16);

disp('');
