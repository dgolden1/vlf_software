function [B, F, T, colorLabel, cax, deltaf] = vlfPlotSpecgram(iiRow, iiCol, DF, bbrec, b_make_ylabel)

% Originally by Maria Spasojevic
% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
if ~exist('b_make_ylabel', 'var') || isempty(b_make_ylabel)
	b_make_ylabel = true;
end

%% Get data
% global DF

data = bbrec.data( DF.channel(iiRow), : );
data = data-mean(data);

%% Make spectrogram
% Round the decimation factor to the nearest power of two less than the
% calculated rate; otherwise the resample function takes forever
decimateFactor = bbrec.sampleFrequency/(DF.maxFreq(iiRow)*2);
decimateFactor = 2^floor(log2(decimateFactor));

data = decimate(data, decimateFactor);
deltaf = bbrec.sampleFrequency/decimateFactor/DF.nfft;

% Reduce spectrogram resolution to reduce file size (e.g., for EPS output)
% if DF.numPlots > 50
% 	img_reduction_factor = round(DF.maxPlots/2);
% elseif DF.numPlots > 20
if DF.process24 || DF.numPlots > 20
	img_reduction_factor = round(DF.maxPlots/4);
else
	img_reduction_factor = max(round(DF.maxPlots/10), 1);
end

data_mask = false(size(data));
idx = 0;
kk = 1;
while idx + DF.window(iiRow) < length(data)
	if rem(kk, img_reduction_factor) == 0
		data_mask(idx+1:idx + DF.window(iiRow)) = true;
	end
	idx = idx + DF.window(iiRow);
	kk = kk + 1;
end
data_reduced = data(data_mask);

% CREATE SPECGRAM
fs_dec = bbrec.sampleFrequency/decimateFactor;
sitename = bbrec.site;
[B, F, T, colorLabel, cax] = spectrogram_cal(data_reduced, DF.window(iiRow), DF.noverlap(iiRow), DF.nfft(iiRow), fs_dec, sitename, bbrec.startDate);

if min(size(B)) == 1
	warning('Only one spectrogram column perserved per synoptic segment');
end

if DF.bContSpec
	return;
end

%% MAKE AXES
pos = [ DF.left+(iiCol-1)*DF.width 1-DF.top-DF.height DF.width DF.height];
pos(1) = DF.left+((iiCol-1)*DF.width);
pos(2) = 1-DF.top-(DF.height*(iiRow))-(DF.vspace*(iiRow-1));
pos(3) = DF.width;
pos(4) = DF.height;

h_ax = axes('Position', pos );
DF.h_ax(iiRow, iiCol) = h_ax;

%% PLOT IMAGE
if DF.useCal && ~strcmp(colorLabel, 'uncal dB')
	scale = [DF.dbScale(iiRow,1) DF.dbScale(iiRow,2)] - 55;
else
	scale = [DF.dbScale(iiRow,1) DF.dbScale(iiRow,2)];
end

imagesc( T, F/1e3, B, scale );
axis xy;

ylim([DF.minFreq(iiRow)/1e3 DF.maxFreq(iiRow)/1e3]);

%% COLORBAR & YLABEL
if b_make_ylabel
	y = [scale(1):0.25:scale(2)];
	x = ones(size(y));

	cpos = pos;
	cpos(1) = DF.left + DF.maxPlots*DF.width;
	cpos(3) = DF.cbar;

	h_cb = axes('Pos', cpos);
	imagesc( x, y, y' );
	axis xy;
	set(h_cb, 'XTick', [], 'YAxisLoca', 'right', 'TickDir', 'out');
	
% 	if( iiRow == 1 )
% 		title('dB');
% 	end;
	ylabel(colorLabel);
	DF.h_cb(iiRow) = h_cb;

	set(DF.fig, 'CurrentAxes', h_ax);
	ylabel('Freq, kHz');
	set(h_ax, 'TickDir', 'out');
else
	set(h_ax, 'YTick', []);
end;

% if(iiCol ~= 1 )
% 	set(h_ax, 'YColor', [0 0.0 0.875]);
% end;

%% X TICKS AND XTICK LABELS
hhmm = datestr(bbrec.startDate, 'HH:MM');
if( DF.maxPlots == 1 )
  xticks = [0:5:60];
  xticklabel{1} = datestr(bbrec.startDate, 'HH:MM:SS');
  for( k = 2:length(xticks) )
    xticklabel{k} = datestr(bbrec.startDate+xticks(k)/60/60/24, ':SS');
  end;
  set(h_ax, 'XTick', xticks, 'TickDir', 'out', 'XTickLabel', xticklabel);
elseif( DF.maxPlots <= 10 )
  set(h_ax, 'XTick', 0, 'XTickLabel', hhmm, 'TickDir', 'out');
elseif( DF.maxPlots > 10 & DF.maxPlots <= 24 )
  if( rem(iiCol, 2)-1 == 0 )
    set(h_ax, 'XTick', 0, 'XTickLabel', hhmm, 'TickDir', 'out');
  else
    set(h_ax, 'XTick', 0, 'XTickLabel', '', 'TickDir', 'out');
  end;
elseif( DF.maxPlots > 24 & DF.maxPlots <= 48 )
  if( rem(iiCol, 4)-1 == 0 )
    set(h_ax, 'XTick', 0, 'XTickLabel', hhmm, 'TickDir', 'out');
  else
    set(h_ax, 'XTick', 0, 'XTickLabel', '', 'TickDir', 'out');
  end;
elseif( DF.maxPlots >= 48 )
  if( rem(iiCol, 8)-1 == 0 )
    set(h_ax, 'XTick', 0, 'XTickLabel', hhmm, 'TickDir', 'out');
  elseif( rem(iiCol, 4)-1 == 0 )
    set(h_ax, 'XTick', 0, 'XTickLabel', '', 'TickDir', 'out');
  else
    set(h_ax, 'XTick', []);
  end;
end;

if( DF.numRows == 2 & iiRow == 1 )
   set(h_ax, 'XTickLabel', []);
end;

if( DF.maxPlots > 2 )
  set(h_ax, 'TickLength', [0.025 0.025] );
end;
