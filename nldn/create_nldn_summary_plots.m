function create_nldn_summary_plots(start_file_num, start_file_denom)
% create_nldn_summary_plots
% Function to create a whole mess of NLDN summary plots
% If start_file_num is 2 and start_file_denom is 5, then this function will plot 1/5 of the total plots, starting 2/5 of the way through and ending 3/5 of the way through

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
fclose all;

if ~exist('start_file_num', 'var') || isempty(start_file_num) || ~exist('start_file_denom', 'var') || isempty(start_file_denom)
	start_file_num = 1;
	start_file_denom = 1;
end

date_start = datenum([2003 01 01 0 0 0]);
date_end = datenum([2003 11 1 0 0 0]);
dates = date_start:1/4:date_end; % Every 6 hours

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
        case 'polarbear'
			output_dir = '/home/dgolden1/output/nldn_plots';
			spec_amp_dir = '/home/dgolden1/input/synoptic_summary_plots/spec_amps';
        case 'quadcoredan.stanford.edu'
			output_dir = '/home/dgolden/vlf/case_studies/nldn/nldn_plots';
			spec_amp_dir = '/home/dgolden/vlf/case_studies/chorus_2003/synoptic_summary_plots/spec_amps';
        otherwise
               error('Unknown host (%s)', hostname(1:end-1));
end

%% Make and print plots
t_start = now;

figure('Color','white');
figure_squish(gcf, 0.7, 0.6);

kk_start = floor(length(dates)*(start_file_num - 1)/start_file_denom + 1);
kk_end = ceil((length(dates) - 1)*start_file_num/start_file_denom);
disp(sprintf('Processing from %s to %s', datestr(dates(kk_start)), datestr(dates(kk_end))));
% nldn_plot_type = 'time';
for kk = kk_start:kk_end
	t_this_start = now;
	clf;
	
	% NLDN
	h_ax = subplot(4, 1, 1:2);
	this_date = dates(kk);
	next_date = dates(kk+1);
	plot_nldn(this_date, next_date, 'flash_type', 'density', 'map_type', 'conus', 'h_ax', h_ax);
	title(sprintf('NLDN flash density %s to %s', datestr(this_date, 0), datestr(next_date, 0)));
	
	% Palmer data
	spec_amp_filename = sprintf('palmer_%s.mat', datestr(this_date, 'yyyymmdd'));
	subplot(4, 1, 3);
	spec_amp = load(fullfile(spec_amp_dir, spec_amp_filename));
	spec_amp.spec_amp = mat2rgb(spec_amp.spec_amp);
	image(spec_amp.t, spec_amp.f, spec_amp.spec_amp); axis xy;
	title(sprintf('Palmer Station %s', datestr(this_date, 1)));

	rectangle('Position', [fpart(this_date), 300, next_date - this_date, 6000 - 300], 'LineWidth', 4, 'EdgeColor', 'r');

%	c = colorbar;
%	caxis([-20 25]);
%	set(get(c, 'ylabel'), 'string', 'dB-fT/Hz^{1/2}');

	ylim([300 6000]);
	datetick('x', 'keeplimits');
	xlabel('Time (UT)');
	ylabel('Frequency (Hz)');
	
	% DST
	h_ax = subplot(4, 1, 4);
	dst_start_date = max(floor(this_date) - 1, date_start);
	dst_end_date = ceil(next_date);
	dst_plot(dst_start_date, dst_end_date, [], h_ax);
	title(sprintf('DST %s to %s', datestr(dst_start_date, 0), datestr(dst_end_date, 0)));
	yl = ylim;
	rectangle('Position', [this_date, yl(1), next_date - this_date, diff(yl)], 'LineWidth', 4, 'EdgeColor', 'r');
	ylim(yl);

	increase_font(gcf, 12);
	
	filename = sprintf('nldn_plot_%s_%s.png', nldn_plot_type, datestr(this_date, 'yyyymmdd_HHMM'));
	print('-dpng', fullfile(output_dir, filename));
	disp(sprintf('Plotted and saved %s in %0.0f seconds', fullfile(output_dir, filename), (now - t_this_start)*86400));

	fclose all; % Some mapping functions leave files open, because they're stupid
end

disp(sprintf('Finished in %0.0f seconds', (now - t_start)*86400));
fclose all;
