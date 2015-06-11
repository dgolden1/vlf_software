function vlfSavePlot
% By Maria Spasojevic
% Modified by Daniel Golden (dgolden1 at stanford dot edu)

% $Id$

global DF;

%% Save image
increase_font(DF.fig, 14);

sfigure(DF.fig);

% There's a bug where saving messes up the position of the main axis
% This kludge fixes it
if isscalar(DF.h_ax)
	pos = get(DF.h_ax, 'position');
	set(DF.h_ax, 'position', [0.07 pos(2) .8 pos(4)]);
	set(DF.h_ax, 'activepositionproperty', 'position');
end

saveName = [DF.saveName '.' DF.saveType];

fullFilePath = fullfile(DF.destinPath, saveName);

% If Matlab was run with the "-nodisplay" option, then Matlab uses
% Ghostscript to print stuff, which lowers the resolution and
% Ignores the -r tag to print(). In this case, we should crank up
% The resolution and the font.
if isprop(DF.fig, 'XDisplay') && strcmp(get(DF.fig, 'XDisplay'), 'nodisplay')
	figure_grow(gcf, 1.4, 1.4)
	increase_font(gcf, 18);
end

if( strcmp( DF.saveType, 'jpg' ) )
	print(DF.fig, '-djpeg100', '-r85', fullFilePath );
elseif strcmp( DF.saveType, 'eps')
	print(DF.fig, '-depsc', fullFilePath );
elseif strcmp( DF.saveType, 'png')
	print(DF.fig, '-dpng', '-r85', fullFilePath );
else
	error('Unknown format for plot save (''%s'')', DF.saveType);
end;


disp(['Wrote ' fullFilePath]);

%% Save spec_amp if applicable
% This should trigger when a 24-hour spectrogram was created
if isfield(DF, 'spec_amp')
	[junk, spec_amp_name] = fileparts(saveName);
	spec_amp_path = fullfile(DF.destinPath, 'spec_amps');
	full_spec_amp_path = fullfile(spec_amp_path, [spec_amp_name '.mat']);
	if ~exist(spec_amp_path, 'dir')
		mkdir(spec_amp_path);
	end
	
	spec_amp = DF.spec_amp;
	save(full_spec_amp_path, '-struct', 'spec_amp');
	
	disp(['Wrote ' full_spec_amp_path]);
end
