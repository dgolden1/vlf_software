
fig = gcf;
clf;

h_ax(1) = subplot(2,2,1);
scale = [-1 2.0];
imagesc( xx, yy, log10(ni), scale );
axis image;
axis xy;
hold on;
plot(Lo, 0, 'ko');
% DRAW EARTH CIRCLE
theta = deg2rad([-90:1:90]);
%h_n = patch( 1.04*cos(theta), 1.04*sin(theta), 'w' );
h_n = patch( cos(theta), sin(theta), 'w' );



h_c = colorbar;
axes(h_c);
ylabel('He+ Number Density, cm3');


h_ax(2) = subplot(2,2,2);
plot( LL, log10(He.*nne) );
axis equal;
hold on;

h_ax(3) = subplot(2,1,2);
hold on;
xlabel('L - Lmin');
ylabel('He+ Density, cm3');
xlim([-2 2]);
%ylim([0 68]);
%ylim([0 5]);
%plot( [-0.05 -0.05], ylim, 'k--');
%plot( [0.05 0.05], ylim, 'k--');
%plot( xlim, [0.707 0.707], 'k-');
%grid minor;

