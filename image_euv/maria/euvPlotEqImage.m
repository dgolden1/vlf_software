function h_ax = euvPlotEqImage( euveq, log, range, gridColor, Lcircle );



if (nargin < 2 )
	log = 1;
end;

if ( log == 1 );
	im = log10( euveq.image );
else
	im = euveq.image;
end;

if( nargin < 3 )
	imagesc( euveq.x, euveq.y, im);
else
	imagesc( euveq.x, euveq.y, im, range );
end;

if( nargin < 4 )
	plotGrid = 1;
	gridColor = 'w';
end;

if( gridColor == 0 )
	plotGrid = 0;
else
	plotGrid = 1;
end;

if(nargin < 5 )
	Lcircle = 4;
end;

hold on;
axis xy;
axis image;

% DRAW CIRCLE EARTH
theta = deg2rad([-90:1:90]);
h_n = patch( cos(theta), sin(theta), 'w' );

theta = deg2rad([90:1:270]);
h_d = patch( cos(theta), sin(theta), 'k' );
set(h_n, 'FaceColor', [0.98 0.98 0.98], 'EdgeColor', 'w');
set(h_d, 'FaceColor', 'k', 'EdgeColor', 'w');


theta = deg2rad([0:1:360]);
if( plotGrid )
  for( k = Lcircle )
	h_l = plot( k.*cos(theta), k.*sin(theta), [gridColor '-'] );
  end;
  mltSpokes(30, gridColor, '-' );
end;

titlestr = datestr(euveq.UT);
titlestr(3) = ' ';
titlestr(7) = ' ';
titlestr = [titlestr ' UT'];
title(titlestr);


h_ax = gca;

set(gca, 'TickDir', 'out' )
set(gca, 'XTick', [-8:1:8], 'YTick', [-8:1:8]);
set(gca, 'XTickLabel', [], 'YTickLabel', [] );
