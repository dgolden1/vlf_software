function vlfPlotSpecgramContinuous(Bt, F, T, titlestr, startDates, colorLabel, cax)
% Plot a continuous version of the spectrogram on one image (instead of
% lots of little images). This version works a lot better when exporting to
% a vector graphics format.

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% Setup
global DF;

% PALMER_LONGITUDE = -64.05;
% PALMER_T_OFFSET = PALMER_LONGITUDE/360;
PALMER_T_OFFSET = -(4+1/60)/24;


% if length(startDates) < 2
% 	error('DF.bContSpec should be false if only plotting one data file');
% end

%% Find data gaps and fill them
if length(startDates) >= 2
	start_date_deltas = round((startDates(2:end) - startDates(1:end-1))*96)/96; % Round to the nearest 15 minutes
	
	min_start_date_delta = 1/96; % Length of time between synoptic periods in days. We assume it's 15 minutes here.
	
	% If we're doing a 24-hour spectrogram, then pad the beginning and end
	% of the spectrogram with zeros. Assume we start at 0005 and end at
	% 2350
	if DF.process24
		B = nan(length(F), size(Bt, 2)*96);
		sec_num = round((fpart(startDates(1)) - 5/1440)*96) + 1; % The section, out of 96 15-min sections, in which this data starts
	else
		B = nan(length(F), size(Bt, 2)*round((startDates(end)-startDates(1))/min_start_date_delta + 1));
		sec_num = 1;
	end
	
	blk_h = size(Bt, 1);
	blk_w = size(Bt, 2);
	for kk = 1:length(start_date_deltas)
		num_gaps = start_date_deltas(kk)/min_start_date_delta - 1;

		% If there's no gap, just shove this chunk of Bt into B
		if num_gaps == 0
			B(:, (blk_w*(sec_num-1)+1):(blk_w*sec_num)) = Bt(:,:,kk);
			sec_num = sec_num + 1;
		% If there's a gap, add this chunk of Bt and then a block (or more) of
		% zeros
		else
			B(:, (blk_w*(sec_num-1)+1):(blk_w*sec_num)) = Bt(:,:,kk);
% 			B(:, (blk_w*(sec_num)+1):(blk_w*(sec_num+num_gaps))) = nan(blk_h, blk_w*num_gaps);
			sec_num = sec_num + 1 + num_gaps;
		end
	end
	% Add the last chunk
	B(:, (blk_w*(sec_num-1)+1):(blk_w*sec_num)) = Bt(:,:,end);

	% More 5-minute rounding; make sure startDates includes all dates in the
	% data set, including any gaps
	startDates = round_to_15(startDates(1)):min_start_date_delta:round_to_15(startDates(end));
	
	% If we're doing a whole day, there may be gaps at the beginning and
	% end of the day. Set the start dates to be the usual synoptic
	% intervals, including potential gaps, so the ticks line up properly
	if DF.process24
		startDates = (5/1440:15/1440:1430/1440) + floor(startDates(1));
	end
else
	B = Bt;
end

%% Plot
% add an extra chunk of time at the end so the ticks represent data start
% times
sfigure(DF.fig);

if length(startDates) > 1
	startDates = [startDates, (startDates(end) + min_start_date_delta)];
else
	startDates = [startDates, startDates + (DF.endSec - DF.startSec)/86400];
end
t = linspace(startDates(1), startDates(end), size(B, 2)+1); t(end) = [];

% Choose color scale
% db_min = DF.dbScale(1,1);
% db_max = DF.dbScale(1,2);
% 
% if DF.useCal
% 	db_min = (db_min - 55)/20;
% 	db_max = (db_max - 55)/20;
% end
db_min = cax(1);
db_max = cax(2);

% figure_squish(DF.fig);
data_length = startDates(end) - startDates(1); % Length of plotted data, in seconds (approximate)
if data_length > 180/86400 % more than 3 min
	imagesc(t, F, B, [db_min db_max]);

	if data_length > 95/96 % A full day
		DF.spec_amp.spec_amp = B;
		DF.spec_amp.t = linspace(0, 1, size(B, 2));
		DF.spec_amp.f = F;
		DF.spec_amp.unit_str = colorLabel;
	end
else
	imagesc(linspace(DF.startSec, DF.endSec, size(B,2)), F, B, [db_min db_max]);
end
DF.h_ax = gca;
set(gca, 'tag', 'bbax');
axis xy;
set(gca, 'TickDir', 'out');

%% colorbar
c = colorbar;
set(get(c, 'ylabel'), 'String', colorLabel);

%% xticks
DF.h_ax_mlt = [];
if data_length > 180/86400 % more than 3 min
	MAXTICKS = 40;
	MAXLABELS = 10;
	[y m d HH MM] = datevec(startDates);
	MM = round(MM/5)*5; % Round to the nearest 5 minutes
	tickDates = startDates;

	if length(tickDates) > 2*MAXTICKS
		tickDates = tickDates(MM == 05);
	elseif length(tickDates) > MAXTICKS
		tickDates = tickDates(MM == 05 | MM == 35);
	end
	while length(tickDates) > MAXTICKS
		tickDates = tickDates(1:2:end);
	end
	startDates = tickDates;
	
	mask = true(size(startDates));
	
	if sum(mask) > MAXLABELS
		mask(~(MM == 05 | MM == 35)) = false;
	end
	if sum(mask) > MAXLABELS
		mask(~(MM == 05)) = false;
	end
	while sum(mask) > MAXLABELS
		mask_trues = find(mask);
		mask(mask_trues(2:2:end)) = false;
	end
	
	xticks = tickDates;
	set(gca, 'xtick', xticks);
	datetick('x', 'HH:MM', 'keeplimits', 'keepticks');

	xticklabels = get(gca, 'xticklabel');
	xticklabels(~mask, :) = ' ';
	set(gca, 'xticklabel', xticklabels);

	% Add MLT
	if DF.showMLT
		xticks_with_names = xticks(mask);
		axes_vec = [xticks_with_names; xticks_with_names + PALMER_T_OFFSET];
		axes_labels = {'UTC', sprintf('MLT\n ')};
		DF.h_ax_mlt = add_x_axes(gca, axes_vec, axes_labels);
		for kk = 1:length(DF.h_ax_mlt)
			datetick(DF.h_ax_mlt(kk), 'x', 'HH:MM', 'keeplimits', 'keepticks');
		end
		set(DF.fig, 'currentaxes', DF.h_ax);

		set(gca, 'xtick', xticks);
  else
    xlabel('UTC');
  end
else
	set(gca, 'xtick', unique(round(get(gca, 'xtick')))); % Remove partial seconds from xticks
	fileStartDate = startDates(1) - DF.startSec/86400;
	% Add MLT
	if DF.showMLT
		xlabel(sprintf('Time (seconds after %s UTC, %s MLT)', ...
			datestr(fileStartDate, 'HH:MM:SS'), datestr(fileStartDate + PALMER_T_OFFSET, 'HH:MM:SS')));
	else
		xlabel(sprintf('Time (seconds after %s UTC)', ...
			datestr(fileStartDate, 'HH:MM:SS'), datestr(fileStartDate + PALMER_T_OFFSET, 'HH:MM:SS')));
	end
end

%% Y limits
ylim([DF.minFreq(1) DF.maxFreq(1)]);

%% other stuff
% figure_squish(gcf, 0.7, 1.4);

ylabel('Frequency (kHz)');
title(titlestr);

if isempty(DF.h_axes) % If this isn't a user-specified axes...
  increase_font(DF.fig, 16);
  pos = get(DF.fig, 'Position');
  if data_length > 60/86400
    set(DF.fig, 'position', [pos(1) pos(2) 12 4.5], 'paperpositionmode', 'auto');
  else
    set(DF.fig, 'position', [pos(1) pos(2) 12 4], 'paperpositionmode', 'auto');
  end
  posa = get(gca, 'Position');
  set(gca, 'position', [0.1 posa(2) 0.78 posa(4)]);

  set(gca, 'units', 'inches');
  posa_in = get(gca, 'outerposition');
  pospp_in = get(gcf, 'paperposition');
  set(DF.fig, 'paperposition', [0 0 posa_in(3) posa_in(4)+.5]);
  % set(DF.fig, 'paperpositionmode', 'auto');
  set(gca, 'units', 'normalized');
end

%% Muddle with extra axes sizing
if length(startDates) > 2 && DF.showMLT % More than one plot
% if data_length > 60/86400 % more than 60 seconds
	op = get(DF.h_ax, 'outerposition');
	set(DF.h_ax, 'outerposition', [op(1) op(2) op(3) 1-op(2)]);
	pos = get(DF.h_ax, 'position');
	for kk = 1:length(DF.h_ax_mlt)
		subpos = get(DF.h_ax_mlt(kk), 'position');
		set(DF.h_ax_mlt(kk), 'position', [pos(1) subpos(2) pos(3) subpos(4)]);
	end
end

%% Function: round_to_15
function output_datenum = round_to_15(input_datenum)
% Round to the nearest 15 minute block, either 5, 20, 35 or 50 minutes
% after the hour
output_datenum = round((input_datenum - 5/1440)*96)/96 + 5/1440;
