function h_text = ecg_write_big_letters(textstr, h_ax)
% h_text = ecg_write_big_letters(text, h_ax)
% Write big text on the spectrogram

global spec_y_max
if spec_y_max > 400
	% Two-level type spectrogram
	x = 450;
	y = 200;
else
	% One-level type spectrogram
	x = 500;
	y = 75;
end

axes(h_ax);
h_text = text(x, y, textstr, 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
	'HorizontalAlignment', 'center');
