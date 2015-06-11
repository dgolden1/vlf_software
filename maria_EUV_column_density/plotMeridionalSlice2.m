figWidth = 8;
figHeight = 8;

fig = findobj('Tag', 'main');
if ( isempty( fig ) )
    fig = figure;
    set( fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'inches', 'Tag', 'main');
    figpos = [ .1 .1 figWidth figHeight ];
    set(fig, 'position', figpos );
else
    figure(fig);
    clf;
end;

top = 0.05;
mid = 0.05;
bot = 0.05;
left = 0.1;
height = (1 - top - bot- mid)/2;
width = height;

%makeGrid;
fillGridDiff;
fillGridConstant;
clf;

scale = [0 5];

h_ax(1) = subplot('Position', [left 1-top-height/2 width height/2]);
hold on;
ii = find(LL > 2 );
plot( LL(ii), log10(nne(ii)) );
xlim([0 6]);
ylim([0 4]);
plot( [4.5 4.5], ylim, 'k-');

h_ax(2) = subplot('Position', [left bot width height]);
imagesc( xx, yy, log10(ne), scale );
%imagesc( xx, yy, log10(ne), [-0.1 5] );
axis image;
axis xy;
hold on;
xlim([0 6]);

set(h_ax, 'TickDir', 'out');

%h_c = colorbar;
%axes(h_c);
%ylabel('Electron Number Density, cm^{-3}');


% DRAW DIPOLE FIELD LINES
L = [2 3 4 4.5 5 6 7 8];
if(1)
for( k = 1:length(L) )  
    lambda = linspace(-pi/2, pi/2, 300);
    r = L(k).*cos(lambda).^2;
    B_x = r.*cos(lambda);
    B_z = r.*sin(lambda);
    h_flr(k) = plot(B_x, B_z, 'k-');
end;
end;

% DRAW EARTH CIRCLE
theta = deg2rad([-90:1:90]);
%h_n = patch( 1.04*cos(theta), 1.04*sin(theta), 'w' );
h_n = patch( cos(theta), sin(theta), 'w' );
ylim([-3 3]);

pos1 = get(h_ax(1), 'Pos');
pos2 = get(h_ax(2), 'Pos');
set( h_ax(1), 'Pos', [pos1(1) pos1(2) pos2(3) pos1(4)]);
