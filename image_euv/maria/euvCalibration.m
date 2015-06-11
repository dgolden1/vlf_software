function euv = euvCalibration( euv )

load('solar304.mat');

a = 0;
for( k = 1:length(solar.UT) )
	if( floor( euv.UT ) == solar.UT(k) )
		euv.image = euv.image .* 2.76e19 ./ solar.solar304(k);
		a = 1;
	end;
end;

if ( a == 0 )
	disp('CALIBRATION IS BROKEN, BROKEN, BROKEN....');
end;

