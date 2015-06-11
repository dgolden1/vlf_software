function vlfProcessDVD
% Modified by Daniel Golden (dgolden1@stanford.edu) Feb 2007

global DF;
global ALLDATA;

pathname = [];
filename = [];
d = dir( [DF.sourcePath DF.wildcard] );

if( ~isempty( d ) )
	for( k = 1:length( d ) )
		pathname{k} = DF.sourcePath;
		filename{k} = d(k).name;
	end;
else
	ddir = dir( DF.sourcePath );
	m = 1;
	for( k = 1:length( ddir ) )
		if( ddir(k).isdir == 1 && ~strcmp(ddir(k).name, '.') && ~strcmp(ddir(k).name, '..')) % Exclude the . and .. directories
			newdir = [DF.sourcePath ddir(k).name DF.dirChar];
			d = dir( [newdir DF.wildcard] );
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

numPlots = length(filename);
if numPlots == 0
	error('No files found on DVD that match wildcard ''%s''', DF.wildcard);
end

if( DF.maxPlots == -1 )
	DF.maxPlots = numPlots;
end;
numPages = ceil( numPlots / DF.maxPlots );

sii = 1;
for( m = 1:numPages )

	eii = sii+DF.maxPlots-1;
	if( eii > numPlots )
		eii = numPlots;
	end;
	DF.filename = filename([sii:eii]);
	DF.pathname = pathname([sii:eii]);
	DF.numPlots = length(DF.filename);

    if (ALLDATA)
        whFullDataPlots;
    else
        vlfNewFigure('bbfig1');
        vlfMakePage;
        if( DF.savePlot == 1 )
            vlfSavePlot;
        end;
    end
	sii = eii+1;

end;
