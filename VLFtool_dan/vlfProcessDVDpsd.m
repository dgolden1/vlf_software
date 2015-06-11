function [UT, f, vlfpsd] = vlfProcessDVDpsd

global DF;

pathname = [];
filename = [];

wildcard = '*.mat';
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

numFiles = length(filename);

vlfpsd = [];
UT = [];
freq = [];
for ( k = 1:numFiles )

	vlfLoadData( filename{k}, pathname{k}, [10 60] );
	[p, f] = vlfCalcPSD(256);
	DF.VLF.UT = [DF.VLF.UT DF.bbrec.startDate];
	DF.VLF.freq = f;
	DF.VLF.psd = [DF.VLF.psd p];
	
    VLF = DF.VLF;
	VLF.site = DF.bbrec.site;

	savename = [ 'tmp.mat'];
	save( [DF.destinPath savename], 'VLF');
	disp(['----------- ' num2str( k ) ' / ' num2str( numFiles )]); 
    
end;

