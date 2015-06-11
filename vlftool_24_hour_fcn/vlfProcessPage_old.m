function vlfProcessPage
% $Id$

global DF;

%% Loop over subplots
startDates = zeros(1, DF.numPlots);
for( k = 1:DF.numPlots )

%   disp(['** ' num2str(k) ' (' DF.filename{k} ') **']);
  disp(sprintf('Processing segment %d of %d (%s)', k, DF.numPlots, DF.filename{k}));

%   % Skip over files with errors
%   try
	  vlfLoadData( DF.filename{k}, DF.pathname )
%   catch
% 	  er = lasterror;
% 	  warning(er.message);
% 	  fclose('all'); % Make sure the file got closed
% 	  continue;
%   end
  
  if( isempty( DF.bbrec.data ) )
    continue;
  end;

  startDates(k) = DF.bbrec.startDate;
  
  if( k == 1 )
	if DF.bContSpec
	    vlfNewFigure( 'bbfig' );
	else
	    vlfNewFigureOriginal( 'bbfig' );
	end
    
    set(DF.fig, 'Name', datestr( DF.bbrec.startDate, 'yyyymmdd') );

    sitename = lower(DF.bbrec.site(:).');
    b = setxor(findstr(sitename, ' '), [1:length(sitename)]);
    sitename = sitename(b);

% 	if ~DF.bContSpec
% 		h_t = axes( 'Pos', [DF.titleX  DF.titleY 0.001 0.001]);
% 		set(h_t, 'Visible', 'off');
% 	end
    doy = jday(DF.bbrec.startDate);
    titlestr = ['Stanford VLF    ' DF.bbrec.site_pretty ' Station    ' ...
      datestr( DF.bbrec.startDate, 'yyyy mmm dd') ' (Day ' doy ')    ' ...
      num2str( DF.endSec - DF.startSec ) ];

    if( DF.numPlots == 1 )
      DF.saveName = [sitename '_' datestr( DF.bbrec.startDate,  'yyyymmdd_HHMM') ];
      titlestr = [titlestr ' sec snapshot'];
    elseif( DF.process24 )
      DF.saveName = [sitename '_' datestr( DF.bbrec.startDate,  'yyyymmdd') ];
      titlestr = [titlestr ' sec snapshots / 15 min gaps'];
    else
      DF.saveName = [sitename '_' datestr( DF.bbrec.startDate,  'yyyymmdd_HHMM-') ];
      titlestr = [titlestr ' sec snapshots / 15 min gaps'];
    end;
	
	if ~DF.bContSpec
		h_t = axes( 'Pos', [DF.titleX  DF.titleY 0.001 0.001]);
		set(h_t, 'Visible', 'off');
		text(0, 0, titlestr, 'Horiz', 'center');
	end
  end;

  if( ~DF.process24 )
    iiCol = k;
  else
    iiCol = determineCol24;
  end;

  [B, F, T, colorLabel, cax] = vlfPlotSpecgram( 1, iiCol);
  
%   if ~DF.bContSpec
% 	  title(titlestr);
%   end
  
  if k == 1
	  Bt = zeros(size(B, 1), size(B, 2), DF.numPlots);
	  Tt = zeros(1, length(T), DF.numPlots);
  end
  Bt(:, :, k) = B;
  Tt(:, :, k) = T;
	
  if( DF.numRows > 1 )
	    vlfPlotSpecgram( 2, iiCol);
  end
  
end;

if( DF.numPlots > 1 && ~DF.process24 )
   DF.saveName = [DF.saveName datestr( DF.bbrec.startDate, 'HHMM')];
end;


%% Make the continuous spectrogram if requested

if DF.bContSpec
	vlfPlotSpecgramContinuous(Bt, F, Tt, titlestr, startDates, colorLabel, cax);
end


%% Function: determineCol24
function iiCol = determineCol24
% determine which column snapshot goes into
% assume doing 1/15 synoptic

global DF;

hh = str2num(datestr( DF.bbrec.startDate, 'HH' ) );
mm = str2num(datestr( DF.bbrec.startDate, 'MM' ) );

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
