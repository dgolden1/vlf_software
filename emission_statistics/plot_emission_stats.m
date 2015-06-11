function plot_emission_stats(events, synoptic_epochs, plotwhat, em_type, start_datenum, end_datenum, hist_type, cum_spec_type, color_represents, ax)
% plot_emission_stats(events, plotwhat, em_type, start_datenum, end_datenum, hist_type, cum_spec_type, color_represents, ax)


% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% Revised September 2010 to use my new neural network method of
% characterizing chorus and hiss
% $Id$

%% General Parameters
% year = 2009;
year = 'all';

if (~exist('start_datenum', 'var') || isempty(start_datenum)) && (~exist('end_datenum', 'var') || isempty(end_datenum))
	bAllEvents = true;
	start_datenum = 0;
	end_datenum = inf;
elseif exist('start_datenum', 'var') && ~isempty(start_datenum) && (~exist('end_datenum', 'var') || isempty(end_datenum))
	% User provided year
	year = start_datenum;
	bAllEvents = true;
	start_datenum = 0;
	end_datenum = inf;
elseif exist('start_datenum', 'var') && ~isempty(start_datenum) && exist('end_datenum', 'var') && ~isempty(end_datenum)
	[year, ~] = datevec(start_datenum);
	bAllEvents = false;
else
	bAllEvents = false;
end

if ~exist('plotwhat', 'var') || isempty(plotwhat)
% 	plotwhat = 'intensity';
% 	plotwhat = 'f_c';
% 	plotwhat = 'f_range';
% 	plotwhat = 'TOD';
	plotwhat = 'hist';
% 	plotwhat = 'cum_spec';
% 	plotwhat = 'cum_spec_occur_prob';
% 	plotwhat = 'cum_spec_v3';
% 	plotwhat = 'scatter';
end
if ~exist('em_type', 'var') || isempty(em_type)
% 	em_type = 'all';
% 	em_type = 'chorus';
	em_type = 'hiss';
end
if ~exist('hist_type', 'var') || isempty(hist_type) 
% 	hist_type = 'time_occur';
% 	hist_type = 'time_occur_polar';
	hist_type = 'month_occur';
% 	hist_type = 'year_occur';
%   hist_type = 'solarcycle_occur';
% 	hist_type = 'kp_occur';
% 	hist_type = 'kp_only';
% 	hist_type = 'sum_kp_occur';
% 	hist_type = 'sum_kp_only';
% 	hist_type = 'dst_corr';
% 	hist_type = 'kp_corr';
% 	hist_type = 'ae_corr';
% 	hist_type = 'dst_occur';
% 	hist_type = 'dst_only';
% 	hist_type = 'dst_norm_occur';
% 	hist_type = 'ae_norm_occur';
% 	hist_type = 'kp_norm_occur';
% 	hist_type = 'ae_ampl_scatter_ae';
% 	hist_type = 'hist_radial_occur';
% 	hist_type = 'freq_occur';
end

addl_title_text = '';

%% cum_spec parameters
if ~exist('cum_spec_type', 'var')
	cum_spec_type = 'all';
% 	cum_spec_type = 'kp_high';
% 	cum_spec_type = 'kp_low';
% 	cum_spec_type = 'ae_cross_low';
% 	cum_spec_type = 'ae_cross_high';
% 	cum_spec_type = 'pp_low';
% 	cum_spec_type = 'pp_high';
%  	cum_spec_type = 'radial';
%	cum_spec_type = 'radial_occur';
end
% b_cum_spec_mask = true;
b_cum_spec_mask = false;

%% TOD parameters
if ~exist('color_represents', 'var') || isempty(color_represents)
	color_represents = 'intensity';
% 	color_represents = 'dst';
% 	color_represents = 'kp';
% 	color_represents = 'sum_kp';
% 	color_represents = 'em_type';
end

%% Hist Parameters
% normalize_oc_rate = 'to_events';
normalize_oc_rate = 'to_days';
% normalize_oc_rate = 'none';

% normalize_oc_rate = false;

%% Scatter parameters
if ~exist('scatter_dep_var', 'var') || isempty(scatter_dep_var)
	scatter_type = 'intensity';
end

%% Load events
if ~exist('events', 'var') || isempty(events)
  db_dir = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/databases';
  if isnumeric(year)
    load(fullfile(db_dir, sprintf('auto_chorus_hiss_db_em_char_%04d.mat', year)), 'events');
  elseif strcmp(year, 'all')
    fprintf('Loading the full events struct takes a while.  Try pre-loading it and passing it in as an argument.\n');
    load(fullfile(db_dir, 'auto_chorus_hiss_db_em_char_all_reprocessed.mat'), 'events');
  end
end

if ~exist('synoptic_epochs', 'var') || isempty(synoptic_epochs)
  dg = load('data_gaps.mat');
  synoptic_epochs = dg.synoptic_epochs(dg.b_data);
end
event_datenums = [events.start_datenum];
synoptic_epochs = synoptic_epochs(synoptic_epochs >= min(event_datenums) ...
  & synoptic_epochs <= max(event_datenums));

%% Parse out events for given dates
% The event datenums are still in UTC
these_events = emission_time_parser(events, em_type, bAllEvents, start_datenum, end_datenum);

%% Different types of plots
if exist('ax', 'var') && ~isempty(ax) && all(ishandle(ax));
	saxes(ax(1));
elseif ~exist('ax', 'var')
  ax = [];
end

switch plotwhat
%% Plot: intensity
	case 'intensity'
		scatter(dates, intensity, 'filled');
		ylabel('Intensity (uncal dB)');
%% Plot: f_c
	case 'f_c'
		min_marker_size = 32;
		max_marker_size = 128;
		intensity_norm = (intensity - min(intensity))/(max(intensity) - min(intensity)) * ...
			(max_marker_size - min_marker_size) + min_marker_size;
		scatter(dates, f_center, intensity_norm, intensity, 'filled');
		ylabel('Center frequency');
		c = colorbar;
		set(get(c, 'YLabel'), 'String', 'Intensity (uncal dB)');
%% Plot: f_range
	case 'f_range'
		plot_f_range(these_events, em_type);
%% Plot: TOD
	case 'TOD'
		emstat_tod(dates, these_events, em_type, color_represents, intensity);
%% Plot: hist
	case 'hist'
		switch hist_type
			case 'time_occur'
				emstat_hist_time_occur(these_events, synoptic_epochs, em_type, normalize_oc_rate);
			case 'time_occur_polar'
				emstat_hist_time_occur(em_type, these_events, normalize_oc_rate, 'polar');
			case 'month_occur'
				emstat_hist_month_occur(these_events, synoptic_epochs, em_type, ax);
			case 'year_occur'
				emstat_hist_year_occur(these_events, synoptic_epochs, em_type, ax);
      case 'solarcycle_occur'
        emstat_hist_solarcycle_occur(these_events, synoptic_epochs, em_type, ax);
			case 'kp_occur'
				emstat_hist_kp_occur(dates, normalize_oc_rate);
			case 'kp_only'
				emstat_hist_kp_only(normalize_oc_rate);
			case 'sum_kp_occur'
				emstat_hist_sum_kp_occur(dates, normalize_oc_rate);
			case 'sum_kp_only'
				emstat_hist_sum_kp_only(normalize_oc_rate);
			case 'dst_corr'
				emstat_hist_idx_corr(dates, these_events, 'dst')
			case 'kp_corr'
				emstat_hist_idx_corr(dates, these_events, 'kp')
			case 'ae_corr'
				emstat_hist_idx_corr(dates, these_events, 'ae')
			case 'dst_occur'
				emstat_hist_dst_occur(dates, normalize_oc_rate);
			case 'dst_norm_occur'
				emstat_hist_idx_norm_occur(em_type, these_events, 'dst');
			case 'dst_only'
				emstat_hist_dst_only(normalize_oc_rate);
			case 'ae_norm_occur'
				emstat_hist_idx_norm_occur(em_type, these_events, 'ae');
			case 'ae_ampl_scatter_dst'
				emstat_hist_idx_ampl_scatter(em_type, these_events, 'dst');
			case 'ae_ampl_scatter_kp'
				emstat_hist_idx_ampl_scatter(em_type, these_events, 'kp');
			case 'ae_ampl_scatter_ae'
				emstat_hist_idx_ampl_scatter(em_type, these_events, 'ae');
			case 'kp_norm_occur'
				emstat_hist_idx_norm_occur(em_type, these_events, 'kp');
			case 'hist_radial_occur'
				plot_hist_radial_occur(these_events, normalize_oc_rate);
			case 'freq_occur'
				emstat_hist_freq_occur(em_type, these_events);
			otherwise
				error('Invalid value for hist_type (''%s'')', hist_type);
		end
		
%% Plot: scatter
	case 'scatter'
		switch scatter_type
			case 'intensity'
				emstat_scatter_intensity(events);
			otherwise
				error('Invalid value for scatter_dep_var (''%s'')', scatter_dep_var);
		end
		
%% Plot: cum_spec
	case 'cum_spec'
		plot_cum_spec(these_events, em_type);
%% Plot: cum_spec_v3 / cum_spec_occur_prob
	case {'cum_spec_occur_prob', 'cum_spec_v3'}
		if b_cum_spec_mask
			mask_str = 'mask'; %#ok<UNRCH>
		else
			mask_str = '';
    end
    
    if isempty(cum_spec_type)
      cum_spec_type = '';
    end
    
		switch cum_spec_type
			case 'kp_high'
				kp_lower_bound = 4;

				[kp_date, kp] = kp_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/kp/kp_2003.txt');
				kpi = interp1(kp_date, kp, dates);
				these_events = these_events(kpi >= kp_lower_bound);
				if strcmp(plotwhat, 'cum_spec_occur_prob')
					plot_cum_spec_occur_prob(these_events, em_type);
				else
					plot_cum_spec_v3(these_events, em_type, [], mask_str);
				end
				addl_title_text =  sprintf(' (kp >= %d)', kp_lower_bound);
			case 'kp_low'
				kp_upper_bound = 3;

				[kp_date, kp] = kp_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/kp/kp_2003.txt');
				kpi = interp1(kp_date, kp, dates);
				these_events = these_events(kpi < kp_upper_bound);
				if strcmp(plotwhat, 'cum_spec_occur_prob')
					plot_cum_spec_occur_prob(these_events, em_type);
				else
					plot_cum_spec_v3(these_events, em_type, [], mask_str);
				end
				addl_title_text =  sprintf(' (kp < %d)', kp_upper_bound);
			case 'ae_cross_high'
% 				ae_lower_bound = 700;
				[ae_date, ae] = ae_read_datenum('/home/dgolden/vlf/case_studies/ae/ae_2003.txt');
				
				ae_star = get_idx_star(ae, ae_date, dates, 6, 'max');
				ae_lower_bound = 50*round(mean(ae_star)/50) + 50;

				these_events = these_events(ae_star > ae_lower_bound);
				if strcmp(plotwhat, 'cum_spec_occur_prob')
					plot_cum_spec_occur_prob(these_events, em_type);
				else
					plot_cum_spec_v3(these_events, em_type, [], mask_str);
				end
				addl_title_text =  sprintf(' (ae\\_cross > %d)', ae_lower_bound);
			case 'ae_cross_low'
% 				ae_upper_bound = 600;
				[ae_date, ae] = ae_read_datenum('/home/dgolden/vlf/case_studies/ae/ae_2003.txt');
				
				ae_star = get_idx_star(ae, ae_date, dates, 6, 'max');
				ae_upper_bound = 50*round(mean(ae_star)/50) - 50;
				
				these_events = these_events(ae_star < ae_upper_bound);
				if strcmp(plotwhat, 'cum_spec_occur_prob')
					plot_cum_spec_occur_prob(these_events, em_type);
				else
					plot_cum_spec_v3(these_events, em_type, [], mask_str);
				end
				addl_title_text =  sprintf(' (ae\\_cross < %d)', ae_upper_bound);
			case {'pp_low', 'pp_high'}
				load('/home/dgolden/vlf/case_studies/image_euv_2001/palmer_pp_db.mat', 'palmer_pp_db');
				[mapped_pp, idx_valid, idx_finite] = get_pp_values_on_em_datenums(palmer_pp_db, [these_events.start_datenum].');
				
				if strcmp(cum_spec_type, 'pp_low')
					these_events_pp_low = these_events(idx_valid & mapped_pp >= 2.65 & mapped_pp <= 2.85);
					plot_cum_spec_v3(these_events_pp_low, em_type, [], mask_str);
				elseif strcmp(cum_spec_type, 'pp_high')
					these_events_pp_high = these_events(idx_valid & mapped_pp >= 3.04 & mapped_pp <= 4.23);
					plot_cum_spec_v3(these_events_pp_high, em_type, [], mask_str);
				end
			case 'radial'
				if strcmp(plotwhat, 'cum_spec_occur_prob')
					plot_cum_spec_occur_prob(these_events, em_type);
				else
					plot_cum_spec_v2_radial(these_events, em_type);
				end
			case 'radial_occur'
				if strcmp(plotwhat, 'cum_spec_occur_prob')
					plot_cum_spec_occur_prob(these_events, em_type);
				else
					plot_cum_spec_v2_radial(these_events, em_type);
				end
			otherwise
				if strcmp(plotwhat, 'cum_spec_occur_prob')
					plot_cum_spec_occur_prob(these_events, em_type);
				else
					plot_cum_spec_v3(em_type, these_events, synoptic_epochs, [], mask_str, ax);
				end
		end
	otherwise
		error('Invalid value for plotwhat (''%s'')', plotwhat);
end

%% Axis wrangling
% h = gca;
% if ~(strcmp(plotwhat, 'cum_spec_v3') && strcmp(cum_spec_type, 'radial_occur')) && ...
% 	~(strcmp(plotwhat, 'hist') && strcmp(hist_type, 'hist_radial_occur'))
% 	grid on;
% end
% if ~(strcmp(plotwhat, 'hist') && (strcmp(hist_type, 'kp_only') || ...
% 		strcmp(hist_type, 'dst_only') || strcmp(hist_type, 'sum_kp_only'))) && ...
% 		~strcmp(plotwhat, 'scatter');
% 	title(sprintf('VLF emission events (%s, %d events) %d %s', strrep(em_type, '_', '\_'), ...
% 	length(these_events), year, addl_title_text));
% end
% switch plotwhat
% 	case {'TOD', 'hist', 'cum_spec'}
% 		% Do nothing
% 	case {'intensity', 'f_c'}
% 		xticks = linspace(start_datenum, end_datenum, 10);
% 		set(h, 'XTick', xticks);
% 		datetick('x', 'keeplimits');
% 		xlabel('Day');
% end
% increase_font(gcf, 14);
