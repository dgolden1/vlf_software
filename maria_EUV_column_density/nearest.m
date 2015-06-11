function ii = nearest( a, num );

sizeOfA = size(a);

if( size(a,1) == 1 | size(a,2) == 1 )
	[y, ii] = min( abs(a - num) );
else
	[y, ii] = min( abs(a - num), [], 1 );
	[y, jj] = min( min( abs(a - num) ) );
	ii = [ii(jj) jj];

end;
