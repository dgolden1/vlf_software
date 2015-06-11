function whGetClicks
% This function runs when the user is in Get Points mode whenever there is
% a mouse click detected on the spectrogram.  It saves the time and
% frequency of the click and displays a point on the spectrogram as to
% where the click occured.

% $Id$

global DF
global DATA_SET
global POINT_HANDLES

% initialize the DATA_SET structure if it is empty.  Otherwise, just
% increment the time-freq pair index
if ( ~isstruct( DATA_SET ) || DATA_SET.index == 0)
    if (~isstruct(DATA_SET)) 
        DATA_SET.sferic = -1; 
    end
	DATA_SET.index = 1;
    DATA_SET.UT = DF.bbrec.startDate;
    DATA_SET.station = DF.bbrec.site;
else
	DATA_SET.index = DATA_SET.index + 1;
end;

h = findobj('Tag','spec_axis'); % find the axis

click = get(h, 'CurrentPoint'); % find where the click occured

DATA_SET.time(DATA_SET.index) = click(1,1);
DATA_SET.freq(DATA_SET.index) = click(1,2);

% The following code uses the axis coordinates returned by CurrentPoint to
% get the intensity reading of the image at the given point
% BEGIN
im = findobj('Tag', 'spec_image'); % image of spectrogram

spectimage = get(im,'CData');
[nrows,ncols] = size(spectimage);
xdata = get(im,'XData');
ydata = get(im,'YData');
px = axes2pix(ncols,xdata,click(1,1));
py = axes2pix(nrows,ydata,click(1,2));

r = min(nrows, max(1, round(px)));
c = min(ncols, max(1, round(py)));

DATA_SET.intensity(DATA_SET.index) = spectimage(c,r);

% END

% draw a dot where the click occured
POINT_HANDLES(DATA_SET.index) = plot(click(1,1),click(1,2),...
                'Color','k',...
                'MarkerFaceColor','w',...
                'MarkerEdgeColor','k',...
                'MarkerSize',4,...
                'Marker', 'o');


% update the time frequency display
tv = findobj('Tag','timev');
set(tv, 'String', DATA_SET.time(DATA_SET.index));

fv = findobj('Tag','freqv');
set(fv, 'String', DATA_SET.freq(DATA_SET.index));

iv = findobj('Tag','intensityv');
set(iv, 'String', DATA_SET.intensity(DATA_SET.index));

pv = findobj('Tag','numpointsv');
set(pv, 'String', num2str(DATA_SET.index));

sv = findobj('Tag','sferic_time');
set(sv, 'String', num2str(DATA_SET.sferic, '%0.2f'));

figure(findobj('Tag','getpointsgui'))
