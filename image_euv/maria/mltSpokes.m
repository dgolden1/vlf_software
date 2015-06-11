function h = mltSpokes( incr, col, sym );

if( nargin < 2 )
	col = 'k'	;
end;

if( nargin < 3 )
	sym = '-';
end;

r = [ 2.0 12];

theta = [0:incr:360];

for(k = 1:length(theta) )
	h(k) = plot(r.*cos(theta(k)/180*pi), r.*sin(theta(k)/180*pi), ...
	[col sym]);
	set(h(k), 'Color', col);
end;





