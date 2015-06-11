
% FIGURE SIZE
% UNITS ARE CENTIMETERS
% AGU GUIDELINES http://agu.org/pubs/guides3a.html
% GRL Print, 1 columns, width = 8.4cm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figWidth = 8.3;
figHeight = 4.0;
                                                                                 % CREATE FIGURE AND AXIS OBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fig = findobj('Tag', 'fce');
if ( isempty( fig ) )
    fig = figure;
    set( fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'centimeter', 'Tag', 'fce');
    figpos = [ 1 5 figWidth figHeight ];
    set(fig, 'position', figpos );
else
    figure(fig);
    clf;
end;

loadData = 1;
if( loadData )
	load('R_Beq.mat');
	b.fce = 1.6e-19.*b.b*1e-9/9.11e-31/2/pi/1e3;
	b.fcp = 1.6e-19.*b.b*1e-9/1.6726e-27/2/pi/1e3;
	b.fuhr = sqrt( b.fce .* b.fcp );
end;

left = 0.11;
right = 0.05;
top = 0.04;
bottom = 0.20;

height = 1-top-bottom;
width = 1-left-right;

pos = [left bottom width height];

h_ax = axes('Position', pos);

%%%%%%%%%%%%%%%
% Fce eq
%%%%%%%%%%%%%%%

axes( h_ax );
hold on;

R = [b.R b.R(end:-1:1)];
fce = [b.fce.*0.1 b.fce(end:-1:1)*0.45];
fce = [b.fce.*0.1 b.fce(end:-1:1)*0.5];


%plot( b.R, b.fce.*0.1, 'k-');
%plot( b.R, b.fce.*0.45, 'k-');

patch( R, fce, [0.6 0.6 0.6]);
%plot( b.R, b.fuhr, 'k-');

ylim([0.5 15]);
set(gca, 'YTick', [2.5:2.5:15], 'YTickLabel', {'', '5', '', '10', '', '15'})

set(h_ax, 'TickDir', 'out');

grid on;
