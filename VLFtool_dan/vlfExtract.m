vlfDefaults;
global DF;

pathname = '/mnt/cdrom1/031029/';

[filename, pathname] = uigetfile(DF.sourcePath, ...
    '*.mat', 'MultiSelect', 'On');
                                                                                
if( iscell( filename ) )
    for( k = 1:size( filename, 2 ) )
        DF.pathname{k} = pathname;
        DF.filename{k} = filename{k};
    end;
elseif( ischar( filename ) )
    DF.pathname{1} = pathname;
    DF.filename{1} = filename;
elseif( filename == 0 )
    return;
end;

DF.filename = sort( DF.filename );

for( k = 1:length( DF.filename) )
	
	offset = 0;
	DF.startSec = offset*60+10;	
	DF.endSec = offset*60+15;	

	vlfLoadData( DF.filename{k}, DF.pathname{k} );
	bbrec = DF.bbrec;

	savename = [lower(bbrec.site) '_' ...
		datestr(bbrec.startDate, 'HH') datestr(bbrec.startDate, 'MM') ];
	disp(savename);


	save( savename, 'bbrec');

	if( 0 )
		DF.startSec = 20*60+10;	
		DF.endSec = 20*60+15;	

		vlfLoadData( DF.filename{k}, DF.pathname{k} );
		bbrec = DF.bbrec;

		savename = [lower(bbrec.site) '_' ...
			datestr(bbrec.startDate, 'HH') datestr(bbrec.startDate, 'MM') ];
		save( savename, 'bbrec');
		disp(savename);
	end;



end;

	







