function events = remove_outside_em_int(events, emission_type, b_em_is_local_time)

%% Setup
if ~exist('b_em_is_local_time', 'var') || isempty(b_em_is_local_time)
	b_em_is_local_time = false;
end


%% Everything else

% Convert everything to angles
start_datenum = fpart([events.start_datenum]);
end_datenum = fpart([events.end_datenum]);
em_length = [events.end_datenum] - [events.start_datenum];
mid_datenum = fpart(start_datenum + em_length/2);

switch emission_type
	case 'hiss_only'
		em_int_start = datenum([0 0 0 14 0 0]);
		em_int_end = datenum([0 0 0 23 0 0]);
		em_int_length = em_int_end - em_int_start;
	case {'chorus', 'chorus_only', 'chorus_with_hiss'}
		em_int_start = datenum([0 0 0 03 0 0]);
		em_int_end = datenum([0 0 0 10 0 0]);
		em_int_length = em_int_end - em_int_start;
	otherwise
		error('Invalid emission type (''%s'')', emission_type);
end

% Convert emission interval to UTC if the input emissions are in UTC
if ~b_em_is_local_time
	em_int_start = palmer_lt_to_utc(em_int_start);
	em_int_end = palmer_lt_to_utc(em_int_end);
end


% Remove events that are longer than twice the emission interval,
% and who have neither the start, mid or endpoints inside the
% emission interval
events(em_length > 2*em_int_length | ~(...
	angle_is_between(em_int_start*360, em_int_end*360, start_datenum*360) | ...
	angle_is_between(em_int_start*360, em_int_end*360, mid_datenum*360) | ...
	angle_is_between(em_int_start*360, em_int_end*360, end_datenum*360)...
	)) = [];
