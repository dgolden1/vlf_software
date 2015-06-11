function whColormapChange
% Executes when the user pushes either of the color map radio buttons in
% the color manipulation interface.  Updates the spectrogram to reflect the
% user's desired colormap.

% $Id$

global DF

h = findobj('Tag', 'colorgroup'); % radio button group handle

if (get(h,'SelectedObject') == findobj('Tag','colorradio'))
    set(DF.fig, 'colormap',colormap('jet'));
else
    set(DF.fig, 'colormap',colormap('gray'));
end
