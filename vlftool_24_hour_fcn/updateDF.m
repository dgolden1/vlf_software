function updateDF
% Updates the DF global settings variable

% $Id$

global DF


h = findobj('Tag', 'sourcePath');
DF.sourcePath = get(h, 'String');
if( DF.sourcePath(end) ~= DF.dirChar )
	DF.sourcePath = [DF.sourcePath DF.dirChar];
end;

h = findobj('Tag', 'destinPath');
DF.destinPath = get(h, 'String');
if( DF.destinPath(end) ~= DF.dirChar )
	DF.destinPath = [DF.destinPath DF.dirChar];
end;

h = findobj('Tag', 'maxPlots');
DF.maxPlots = str2num(get(h, 'String'));

h = findobj('Tag', 'wildcard');
wc = get(h, 'String');
DF.wildcard = [];
if(isempty( wc ) )
  DF.wildcard{1} = '*.mat';
else
  iwc = strfind( wc, ', ');
  if ( isempty(iwc) )
    DF.wildcard{1} = wc;
  else
   DF.wildcard{1} = wc(1:iwc(1)-1);
   for( k = 1:length(iwc)-1 )
     DF.wildcard{k+1} = wc(iwc(k)+2:iwc(k+1)-1);
   end;
   DF.wildcard{end+1} = wc(iwc(end)+2:end);
  end;
end;

h = findobj('Tag', 'startSec');
DF.startSec = str2num(get(h, 'String'));
h = findobj('Tag', 'endSec');
DF.endSec = str2num(get(h, 'String'));

h = findobj('Tag', 'savePlots');
DF.bSavePlot = get(h, 'Value');
h = findobj('Tag', 'saveType');
type = get(h, 'Value');
if( type == 1 )
	DF.saveType  = 'jpg';
elseif type == 2
	DF.saveType  = 'eps';
else
	DF.saveType = 'png';
end;

h = findobj('Tag', 'useMLT');
DF.useMLT = get(h, 'Value');
h = findobj('Tag', 'mltOffset');
DF.useMLT = num2str(get(h, 'String'));

row1 = get(findobj('Tag', 'row1'), 'Value');
row2 = get(findobj('Tag', 'row2'), 'Value');
if ( row2 )
	DF.numRows = 2;
else
	DF.numRows = 1;
end;

h = findobj('Tag', 'checkbox_use_cal');
DF.useCal = get(h, 'Value');

h = findobj('Tag', 'checkbox_force_1every15');
DF.bForceEvery15 = get(h, 'Value');
