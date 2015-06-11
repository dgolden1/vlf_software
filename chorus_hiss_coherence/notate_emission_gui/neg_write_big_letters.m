function h_text = neg_write_big_letters(textstr, h_ax)
% h_text = neg_write_big_letters(text, h_ax)
% Write big text on the spectrogram
% Adapted from ecg_write_big_letters()

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

x = 10;
y = 9;

axes(h_ax);
h_text = text(x, y, textstr, 'Color', 'w', 'FontSize', 28, 'FontWeight', 'bold', ...
	'HorizontalAlignment', 'center');
