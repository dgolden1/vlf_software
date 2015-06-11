function vlfPlotSpecgram(iiRow, iiCol)

global DF;


pos = [ DF.left+(iiCol-1)*DF.width 1-DF.top-DF.height DF.width DF.height];
pos(1) = DF.left+((iiCol-1)*DF.width);
pos(2) = 1-DF.top-(DF.height*(iiRow))-(DF.vspace*(iiRow-1));
pos(3) = DF.width;
pos(4) = DF.height;


%figure( DF.fig );
% MAKE AXES
h_ax = axes('Position', pos);

ns_data = DF.bbrec.data( 1, : );
ns_data = ns_data-mean(ns_data);
ew_data = DF.bbrec.data( 2, : );
ew_data = ew_data-mean(ew_data);

if( DF.maxFreq(iiRow)*2 ~= DF.bbrec.sampleFrequency )
	ns_data = resample( ns_data, DF.maxFreq(iiRow)*2, DF.bbrec.sampleFrequency);
	ew_data = resample( ew_data, DF.maxFreq(iiRow)*2, DF.bbrec.sampleFrequency);
end;

[B_ns, F, T] = specgram( ns_data, DF.nfft(1), DF.maxFreq(1)*2, ...
	DF.window(1), DF.noverlap(1));
[B_ew, F, T] = specgram( ew_data, DF.nfft(1), DF.maxFreq(1)*2, ...
	DF.window(1), DF.noverlap(1));

interpCal = interp1( DF.cal.f, DF.cal.ns, F );
for( m = 1:size(B_ns,2) )
	B_ns(:,m) = B_ns(:,m).*interpCal;
end;
interpCal = interp1( DF.cal.f, DF.cal.ew, F );
for( m = 1:size(B_ew,2) )
	B_ew(:,m) = B_ew(:,m).*interpCal;
end;

amp = 20*log10( sqrt( abs( B_ns ).^2 + abs( B_ew ).^2 ) );
az = atan( abs(B_ns)./abs(B_ew) )*180/pi;

scaleDB = [DF.dbScale(iiRow,1) DF.dbScale(iiRow,2)];
scale = [0 90];

for( k = 1:size( az,1) );
	for( m = 1:size(az,2) );
		if( amp(k,m) < scaleDB(1)+10 )
			az(k,m) = -100;
		end;
	end;
end;

cmap = colormap;
cmap(1,:) = [0.8 0.8 0.8];
colormap(cmap);



imagesc( T, F/1e3, az, scale );
axis xy;

ylimit = ylim;
%ylim([0.5 ylimit(2)]);


set(h_ax, 'TickDir', 'out');

% Y LABEL
if( iiCol == 1 )
	ylabel('Freq, kHz');
else
	set(h_ax, 'YTick', []);
end;

% COLORBAR
if( iiCol == DF.numPlots )

	y = [scale(1):0.25:scale(2)];
	x = ones(size(y));

	cpos = pos;
	cpos(1) = cpos(1)+DF.width;
	cpos(3) = DF.cbar;

	h_cb = axes('Pos', cpos);
	imagesc( x, y, y' );
	axis xy;
	set(h_cb, 'XTick', [], 'YAxisLoca', 'right', 'TickDir', 'out');
	
	if( iiRow == 1 )
		title('dB');
		ylabel(colorLabel);
	end;
	axes(h_ax);
end;
	
% TITLE
if( iiRow == 1 )
	if( DF.numPlots <= 12 )
		utMltLabel;		
	elseif( DF.numPlots > 6 & DF.numPlots <= 12 )
		if( rem(iiCol, 4)-1 == 0 )
			utMltLabel;
		end;
	elseif( DF.numPlots > 12 )
		%if( rem(iiCol, 3)-2 == 0 )
		if( rem(iiCol, 4)-1 == 0 )
			utMltLabel;
		end;
	end;
end;

if( DF.numRows == 2 & iiRow == 1)
	if( DF.numPlots == 1 )
		set(h_ax, 'XTickLabel', '');
	else
		set( h_ax, 'XTick', [0], 'XTickLabel', []);
	end;
elseif( DF.numRows == 2 & iiRow == 2 & DF.numPlots ~= 1)
	set( h_ax, 'XTick', [0], 'XTickLabel', [0]);
elseif( DF.numRows == 1 & DF.numPlots ~= 1 )
	set( h_ax, 'XTick', [0], 'XTickLabel', [0]);
end;


function utMltLabel(option)
global DF;

hh = (DF.bbrec.startDate - floor(DF.bbrec.startDate))*24;
ii = nearest( DF.siteMap.UT, hh );

h = title([datestr(DF.bbrec.startDate, 15)]);
titPos = get(h, 'Pos');

if( DF.mltLabel )
	mlt = round(DF.siteMap.MLT(ii)*10)/10;
	ylimit = ylim;
	if( DF.numRows == 2 )
		factor = 1.13;
	else
		factor = 1.17;
	end;

	rmlt = round(mlt);
	if( rmlt == 24 | rmlt == 0 | rmlt == 6 | rmlt == 12 | rmlt == 18 )
		col  = 'b';
	else
		col = 'b';
	end;
	
	text( titPos(1), ylimit(2)*factor, num2str(mlt), ...
		'Color', col, 'Horiz', 'center');
end;



