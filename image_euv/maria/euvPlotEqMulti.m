scale = [9.0 11.0];
scale = [10.0 12];
logscale = 1;
plotColorbar = 0;

h_ax = [];
clf;

eqPath = '/home/maria/IMAGE/EUV/EquatorialMap/11Jul2001/';

origDir = pwd;
cd( eqPath );
[filename, eqPath] = uigetfile('*.*', 'Select Directory' );
cd( origDir );


fileList = {};
d = dir([eqPath '*.fits']);
for ( k = 1:length(d) )
        fileList{end+1} = d(k).name;
end;
fileList = sort(fileList);

selection = 1;
[selection, ok] = listdlg('Name', '', ...
    'PromptString', 'Select File', ...
    'SelectionMode', 'multiple', ...
    'ListSize', [250 300], ...
    'ListString', fileList, ...
    'InitialValue', selection);
if ( ok == 0 )
    return;
end;


maxCol = 3;
if ( length( selection ) < maxCol )
	col = length( selection );
	row = 1;
else
	col = maxCol;
	row = ceil( length( selection ) / col );
end;

for ( k = 1:length(selection) )

    h_ax(k) = subplot( row, col, k );
    eqFile = fileList{ selection(k) };

	euv = euvReadEqDat( eqFile, eqPath, 1, 1 );

	euvPlotEqImage( euv, logscale, scale, 'w', [2 4  6]);
      if( plotColorbar )
        h_cb = colorbar;
        axes(h_cb);
        ylabel('log He^+ Column Density, cm{-2}');
      end;
	
end;

xlimits = [-6.6 6.6];
ylimits = [-6.6 6.6];
set(h_ax, 'XLim', xlimits, 'YLim', ylimits );
ticks = [-6:2:6];
set(h_ax, 'XTick', ticks, 'YTick', ticks);



