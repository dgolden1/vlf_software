function whColorInvert
% executes when the user pushes the invert color button in the color
% manipulation interface.  Inverts the colormap by flipping the colormap
% matrix up to down.

global DF

cmap = get(DF.fig,'colormap');
cmap = flipud(cmap);
set(DF.fig,'colormap',cmap);
