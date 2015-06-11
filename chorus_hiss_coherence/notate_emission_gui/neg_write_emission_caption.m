function caption = neg_write_emission_caption(event, emission_no, str_short_or_long)
% caption = neg_write_emission_caption(event, emission_no, str_short_or_long)
% Create a long or short caption for an event
% str_short_or_long should be one of 'short' or 'long'

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

caption = sprintf('%02d. ', emission_no);
if event.em_type.chorus, caption = [caption, 'chorus, ']; end
if event.em_type.hiss, caption = [caption, 'hiss, ']; end
if event.em_type.corruption, caption = [caption, 'corruption, ']; end
if isempty(caption)
	caption = 'unknown';
else
	caption = caption(1:end-2);
	if ~strcmp(caption(5:end), 'corruption')
		caption = [caption sprintf(' (%d%% conf) ', event.confidence)];
	end
end

switch str_short_or_long
	case 'short'
	case 'long'
		caption = [caption sprintf(' t=[%0.0f %0.0f] f=[%0.1f %0.1f]', ...
			event.t_start, event.t_end, event.f_lc, event.f_uc)];
	otherwise
		error('Caption type must be one of ''short'' or ''long''');
end
