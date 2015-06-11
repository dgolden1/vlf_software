function emstat_tod(dates, these_events, em_type, color_represents, intensity)

days = floor(dates);
times = dates - floor(dates);
switch color_represents
	case 'intensity'
% 				scatter(times, days, intensity_norm, intensity, 'filled');
% 				c = colorbar;
% 				set(get(c, 'Ylabel'), 'String', 'Intensity (dB uncal)');
		c_min = 40;
		c_max = 70;
		c_label = 'Intensity (uncal dB)';
		plot_emission([these_events.start_datenum], [these_events.end_datenum], ...
			[], intensity, em_type, c_min, c_max, c_label);
	case 'dst'
		[dst_date, dst] = dst_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/dst/dst_2003.txt');
		dsti = abs(interp1(dst_date, dst, dates));
		c_min = 0;
		c_max = 150;
		c_label = 'DST (nT)';
		plot_emission([these_events.start_datenum], [these_events.end_datenum], ...
			intensity_norm, dsti, em_type, c_min, c_max, c_label);
	case 'kp'
		[kp_date, kp] = kp_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/kp/kp_2003.txt');
		kpi = interp1(kp_date, kp, dates);
		c_min = 0;
		c_max = 10;
		c_label = 'Kp';
		plot_emission([these_events.start_datenum], [these_events.end_datenum], ...
			intensity_norm, kpi, em_type, c_min, c_max, c_label);
	case 'sum_kp'
		[kp_date, sum_kp] = gen_sum_kp;
		kpi = interp1(kp_date, sum_kp, dates);
		scatter(times, days, intensity_norm, kpi, 'filled');
		c = colorbar;
% 				colormap(flipud(gray));
		caxis([0 60]);
		set(get(c, 'Ylabel'), 'String', '\Sigma Kp');
	case 'em_type'
		chorus_i = cellfun(@(x) ~isempty(strfind(lower(x), 'chorus')), {these_events.emission_type});
		hiss_i = cellfun(@(x) ~isempty(strfind(lower(x), 'hiss')), {these_events.emission_type});
		hiss_events = these_events(hiss_i & ~chorus_i);
		chorus_events = these_events(chorus_i & ~hiss_i);
		chorus_and_hiss_events = these_events(hiss_i & chorus_i);

		plot_emission([hiss_events.start_datenum], [hiss_events.end_datenum], ...
			[], ones(size(hiss_events)), '', 1, 3, '');
		hold on;
		plot_emission([chorus_events.start_datenum], [chorus_events.end_datenum], ...
			[], 2*ones(size(hiss_events)), '', 1, 3, '');
		plot_emission([chorus_and_hiss_events.start_datenum], [chorus_and_hiss_events.end_datenum], ...
			[], 3*ones(size(hiss_events)), '', 1, 3, '');

		
	otherwise
		error('Invalid value for color_represents (''%s'')', color_represents);
end
