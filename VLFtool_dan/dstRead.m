function dst = dstRead( dstfile )
% reads in DST values from a formatted text file

fid = fopen(dstfile);

month = dstfile(end-10:end-8);
if( strcmp( month, 'jan' ) )
	mm = 1;
elseif( strcmp( month, 'feb' ) )
	mm = 2;
elseif( strcmp( month, 'mar' ) )
	mm = 3;
elseif( strcmp( month, 'apr' ) )
	mm = 4;
elseif( strcmp( month, 'may' ) )
	mm = 5;
elseif( strcmp( month, 'jun' ) )
	mm = 6;
elseif( strcmp( month, 'jul' ) )
	mm = 7;
elseif( strcmp( month, 'aug' ) )
	mm = 8;
elseif( strcmp( month, 'sep' ) )
	mm = 9;
elseif( strcmp( month, 'oct' ) )
	mm = 10;
elseif( strcmp( month, 'nov' ) )
	mm = 11;
elseif( strcmp( month, 'dec' ) )
	mm = 12;
end;
year = str2num( dstfile(end-7:end-4) );
UTstart = datenum( year, mm, 0 );

% EXPECTS A 6 LINE HEADER (SEE FILE dst_jun2001.txt)
headerLines = 6;
for ( k = 1:headerLines )
	nextline = fgetl( fid );
end;

tmp = fscanf( fid, '%d', [25, inf]);

q = 1;
for( k = 1:size(tmp,2) )
	for( m = 2:25 )
		dst.UT(q) = UTstart + k + (m-1)/24;
		dst.dst(q) = tmp(m,k);
		q = q +1;
	end;
end;

dst.units = 'nT';

	
