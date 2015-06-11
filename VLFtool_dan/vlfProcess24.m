function vlfProcess24

global DF;
global FIG;
if( isempty( FIG ) )
	FIG.h = [];
	FIG.saveName = [];
end;

pathname = [];
filename = [];

wildcard = DF.wildcard;
% 2001 CDs ?? BEFORE Mar 27 ??
%wildcard = '*20.mat';

maxFigures = 2;
DF.maxPlots = 24;
DF.numPlots = 24;

d = dir( [DF.sourcePath wildcard] );

if( ~isempty( d ) )
	for( k = 1:length( d ) )
		pathname{k} = DF.sourcePath;
		filename{k} = d(k).name;
	end;
else
	ddir = dir( DF.sourcePath );
	m = 1;
	for( k = 1:length( ddir ) )
		if( ddir(k).isdir == 1 )
			newdir = [DF.sourcePath ddir(k).name DF.dirChar];
			d = dir( [newdir wildcard] );
			if( ~isempty( d ) )
				for( p = 1:length(d) )
					pathname{m} = newdir;
					filename{m} = d(p).name;
					m = m+1;
				end;
			end;
		end;
	end;
end;

numPlots = length( filename );


for( k = 1:numPlots )

	disp(['** ' num2str(k) ' **']);
    vlfLoadData( filename{k}, pathname{k} );

	tag = datestr( DF.bbrec.startDate, 1 );
	disp( ['tag = ' num2str(tag)] );
	vlfNewFigure( tag );
	
	if( length( FIG.h ) > 0 )
		haveFig = find( FIG.h == DF.fig);
		if( isempty( haveFig ) )
			haveFig = 0;
		end;
	else
		haveFig = 0;
	end;
	%disp( ['haveFig = ' num2str(haveFig)] );
	if( ~haveFig )
		
		yyyy = datestr( DF.bbrec.startDate, 'yyyy');
        mm = datestr( DF.bbrec.startDate, 'mm');
        dd = datestr( DF.bbrec.startDate, 'dd');
        set(DF.fig, 'Name', [yyyy mm dd]);

		FIG.h = [FIG.h DF.fig];
        FIG.saveName = [FIG.saveName ...
			{[lower(DF.bbrec.site) '_' yyyy mm dd ]}];
		DF.saveName = FIG.saveName{end};

        h_t = axes( 'Pos', [DF.titleX  DF.titleY 0.001 0.001]);
        set(h_t, 'Visible', 'off');
        mmm = datestr( DF.bbrec.startDate, 'mmm');
		doy = jday( DF.bbrec.startDate );
        titlestr = [DF.bbrec.site '   ' yyyy ' ' mmm ' ' dd ...
				' (Day ' doy ')   ' ...
            	num2str( DF.endSec - DF.startSec ) ' sec snapshots'];
        text(0, 0, titlestr, 'Horiz', 'center');

		if( length(FIG.h) > maxFigures )
			DF.fig = FIG.h(1);
			DF.saveName = FIG.saveName{1};

			vlfSavePlot;
			close( DF.fig );
			FIG.h = FIG.h(2:end);
			FIG.saveName = FIG.saveName(2:end);
			DF.fig = FIG.h(end);
			DF.saveName = FIG.saveName{end};
		end;
	else
		DF.fig = FIG.h(haveFig);
		DF.saveName = FIG.saveName{haveFig};
	end;	

    hour = 1+str2num( datestr( DF.bbrec.startDate, 'HH' ) );

    vlfPlotSpecgram( 1, hour);
    if( DF.numRows > 1 )
        vlfPlotSpecgram( 2, hour);
    end;

end;






