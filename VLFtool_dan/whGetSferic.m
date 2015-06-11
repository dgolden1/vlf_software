function whGetSferic
% runs when the user clicks the select sferic button.  changes the
% ButtonDownFcn from whGetClicks to whGetSfericClick.  whGetSfericClick
% switches it back once a sferic is selected
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

global DF
global DATA_SET

h = findobj('Tag', 'spec_image'); % image of spectrogram

% run whGetSfericClick whenever there is a mouse click on the spectrogram
set(h, 'ButtonDownFcn', 'whGetSfericClick');

% change the ponter to help remind user he is selecting a sferic time
set(DF.fig, 'Pointer','Cross');
