function vlfProcessPage
% $Id$

global DF;

%% Create new figure
if DF.bContSpec
	vlfNewFigure( 'bbfig' );
else
	vlfNewFigureOriginal( 'bbfig' );
end

bbrec = vlfLoadData( DF.filename{1}, DF.pathname, DF.startSec(1), DF.endSec(1) );

set(DF.fig, 'Name', datestr( bbrec.startDate, 'yyyymmdd') );

sitename = lower(bbrec.site(:).');
b = setxor(findstr(sitename, ' '), [1:length(sitename)]);
sitename = sitename(b);

doy = jday(bbrec.startDate);
titlestr = ['Stanford VLF  ' bbrec.site_pretty ' Station  ' ...
	datestr( bbrec.startDate, 'yyyy mmm dd') ' (Day ' doy ')  ' ...
	num2str( mean(DF.endSec - DF.startSec) ) ];

if DF.process24
	DF.saveName = [sitename '_' datestr( bbrec.startDate,	'yyyymmdd') ];
	titlestr = [titlestr ' sec snapshots / 15 min gaps'];
elseif( DF.numPlots == 1 )
	DF.saveName = [sitename '_' datestr( bbrec.startDate,	'yyyymmdd_HHMM') ];
	titlestr = [titlestr ' sec snapshot'];
else
	DF.saveName = [sitename '_' datestr( bbrec.startDate,	'yyyymmdd_HHMM-') ];
	titlestr = [titlestr ' sec snapshots / 15 min gaps'];
end;

if ~DF.bContSpec
	h_t = axes( 'Pos', [DF.titleX	DF.titleY 0.001 0.001]);
	set(h_t, 'Visible', 'off');
	text(0, 0, titlestr, 'Horiz', 'center');
end

%% Initialize matrices
if( DF.process24 )
	iiCol = determineCol24(bbrec);
elseif length(DF.filename) == 1
	iiCol = 1;
else
	iiCol = 1;
end

[B, F, T, colorLabel, cax, deltaf] = vlfPlotSpecgram( 1, iiCol, DF, bbrec);
Bt = zeros(size(B, 1), size(B, 2), DF.numPlots);
Tt = zeros(1, length(T), DF.numPlots);

DF.deltaf = deltaf;

%% Loop over subplots
startDates = zeros(1, DF.numPlots);
for( kk = 1:DF.numPlots )
% parfor( kk = 1:DF.numPlots )
% for( kk = 1:DF.numPlots )
	% Commented out for the sake of batch processing!
	% disp(sprintf('Processing segment %d of %d (%s)', kk, DF.numPlots, DF.filename{kk}));
	[startDates(kk), B, T] = process_single_subplot(kk, DF);
	
	Bt(:, :, kk) = B;
	Tt(:, :, kk) = T;
end

if( DF.numPlots > 1 && ~DF.process24 )
	 DF.saveName = [DF.saveName datestr( bbrec.startDate, 'HHMM')];
end;


%% Make the continuous spectrogram if requested

if DF.bContSpec
	vlfPlotSpecgramContinuous(Bt, F, Tt, titlestr, startDates, colorLabel, cax);
end


%% Function: determineCol24
function iiCol = determineCol24(bbrec)
% determine which column snapshot goes into
% assume doing 1/15 synoptic

hh = str2num(datestr( bbrec.startDate, 'HH' ) );
mm = str2num(datestr( bbrec.startDate, 'MM' ) );

iiCol = hh*4 + 1;

if( mm <= 15 )
	iiCol = iiCol + 0;
elseif( mm > 15 & mm <= 30 )
	iiCol = iiCol + 1;
elseif( mm > 30 & mm <= 45 )
	iiCol = iiCol + 2;
elseif( mm > 45 & mm <= 60 )
	iiCol = iiCol + 3;
end;

%% Function: process_single_subplot
function [startdate, B, T] = process_single_subplot(kk, DF)
% Process a single subplot. Used for parallel computation

bbrec = vlfLoadData( DF.filename{kk}, DF.pathname, DF.startSec(kk), DF.endSec(kk), DF.bCombineChannels );

if( isempty( bbrec.data ) )
	startdate = [];
	return;
end;

startdate = bbrec.startDate;

if( DF.process24 )
	iiCol = determineCol24(bbrec);
else
	iiCol = kk;
end;

if kk == 1
	b_make_ylabel = true;
else
	b_make_ylabel = false;
end

[B, F, T, colorLabel, cax] = vlfPlotSpecgram( 1, iiCol, DF, bbrec, b_make_ylabel);

if( DF.numRows > 1 )
	vlfPlotSpecgram( 2, iiCol, DF, bbrec, b_make_ylabel);
end
