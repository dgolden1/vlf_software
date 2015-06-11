function vlfPlotSpecgram(iiRow, iiCol)
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

global DF;

%% Determine position of axis
pos = [ DF.left+(iiCol-1)*DF.width 1-DF.top-DF.height DF.width DF.height];
pos(1) = DF.left+((iiCol-1)*DF.width);
pos(2) = 1-DF.top-(DF.height*(iiRow))-(DF.vspace*(iiRow-1));
pos(3) = DF.width;
pos(4) = DF.height;

h_ax = axes('Position', pos);


%% Extract and downsample data
data = DF.bbrec.data( DF.channel(iiRow), : );
data = data-mean(data);

if( DF.maxFreq(iiRow)*2 ~= DF.bbrec.sampleFrequency )
	data = resample( data, DF.maxFreq(iiRow)*2, DF.bbrec.sampleFrequency);
end;

%% Create spectrogram
[B, F, T] = specgram( data, DF.nfft(iiRow), DF.maxFreq(iiRow)*2, ...
	DF.window(iiRow), DF.noverlap(iiRow));

% Take Magnitude
B = abs(B);


%% Apply calibration and scaling
if( DF.useCal )

	%% LOAD PROPER CALIBRATION
	if( strcmpi( DF.bbrec.site(end-1:end) , 'bb' ) )
		load('palmerbbCal_01Nov2003.mat');
	else
		load('palmerCal_01Nov2003.mat');
	end;
	DF.cal = cal;

		
	if DF.channel(iiRow) == 1
		interpCal = interp1( DF.cal.f, DF.cal.ns, F );
	else
		interpCal = interp1( DF.cal.f, DF.cal.ew, F );
	end;
	
	B = B.*repmat(interpCal, 1, size(B,2));

	B = sqrt(2)*2*B.^2./sum(hanning( DF.window(iiRow) ));
	if( strcmp(DF.units, 'density' ) )
		B = B./(DF.maxFreq(iiRow)*2);
		B = 10*log10( B ./ ( 1/100e3 ) );
		colorLabel = 'wrt 10^{-29} T^2 Hz^{-1}';
	else
		B = 10*log10( B );
		colorLabel = 'wrt 10^{-24} T^2';
	end;

else
	B = 20*log10(B);
	colorLabel = 'uncal';
end;

if( DF.colorScale == 1 )
	scale = [DF.dbScale(iiRow,1) DF.dbScale(iiRow,2)];
else
	maxB = mean(max(B));
	minB = mean(min(B));
	scale = [minB maxB];
end;

%% Create the spectrogram
% T begins at 0; add DF.startSec to get the appropriate offset from the
% start of this data file
spec = imagesc( T+DF.startSec, F/1e3, B, scale );
axis xy;
xlim(round(xlim)); % Round the xlimits to integer values

set(spec,'Tag','spec_image');

%% Y limit and labels
ylimit = ylim;
ylim([0.5 ylimit(2)]);

set(h_ax, 'TickDir', 'out');

% Y LABEL
if( iiCol == 1 )
	ylabel('Freq, kHz');
else
	set(h_ax, 'YTick', []);
end;

%% Colorbar
if( iiCol == DF.numPlots )

	y = (scale(1):0.25:scale(2));
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
	
%% Title
if( iiRow == 1 )
	if( DF.numPlots <= 12 )
		utMltLabel;		
	elseif( DF.numPlots > 6 && DF.numPlots <= 12 )
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

%% Manipulate the x-axis
% For multiple axes on a single figure, nuke the x-axis.
if( DF.numRows == 2 && iiRow == 1)
	if( DF.numPlots == 1 )
		set(h_ax, 'XTickLabel', '');
	else
		set( h_ax, 'XTick', 0, 'XTickLabel', []);
	end;
elseif( DF.numRows == 2 && iiRow == 2 && DF.numPlots ~= 1)
	set( h_ax, 'XTick', 0, 'XTickLabel', 0);
elseif( DF.numRows == 1 && DF.numPlots ~= 1 )
	set( h_ax, 'XTick', 0, 'XTickLabel', '');
else
     % Otherwise, label the x-axis as seconds after the start of this file
	xlabel(sprintf('Seconds after %s', datestr(DF.bbrec.startDate - DF.startSec/86400, 13)));
end;


%% Enable data point collection
set(h_ax, 'Tag', 'spec_axis');
set(h_ax, 'NextPlot', 'add'); % Make sure that the next thing plotted on this axis doesn't replace the spectrogram
if( iiCol == DF.numPlots )
    set(h_cb, 'Tag', 'colorbari');
end


%% Function: utMltLabel
function utMltLabel
% Magnetic local time

global DF;

hh = (DF.bbrec.startDate - floor(DF.bbrec.startDate))*24;
ii = nearest( DF.siteMap.UT, hh );

h = title(datestr(DF.bbrec.startDate, 13)); % changed so that it showed the start second as well
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
	if( rmlt == 24 || rmlt == 0 || rmlt == 6 || rmlt == 12 || rmlt == 18 )
		col  = 'b';
	else
		col = 'b';
	end;
	
	text( titPos(1), ylimit(2)*factor, num2str(mlt), ...
		'Color', col, 'Horiz', 'center');
end;



