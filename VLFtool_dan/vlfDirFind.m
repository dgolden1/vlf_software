
pathname = '/home/maria/VLF/CaseEvents/Halloween2003/031028/';
filename = 'palmerbb_0735.mat';

d = dir( [pathname 'palmerbb_07*.mat']);

for( k = 1:length(d) )

	figure;
	load([pathname d(k).name]);
	%load(fullfile(pathname, filename));



	ns_data = bbrec.data(1,:);
	ns_data = ns_data - mean(ns_data);
	ew_data = bbrec.data(2,:);
	ew_data = ew_data - mean(ew_data);

	ns_data = resample( ns_data, 30e3, 100e3);
	ew_data = resample( ew_data, 30e3, 100e3);

	[B_ns, F, T] = specgram( ns_data, DF.nfft(1), 30e3, ...
    	DF.window(1), DF.noverlap(1));
	[B_ew, F, T] = specgram( ew_data, DF.nfft(1), 30e3, ...
    	DF.window(1), DF.noverlap(1));


	interpCal = interp1( DF.cal.f, DF.cal.ns, F );
	for( m = 1:size(B_ns,2) )
		B_ns(:,m) = B_ns(:,m).*interpCal;
	end;
	interpCal = interp1( DF.cal.f, DF.cal.ew, F );
	for( m = 1:size(B_ew,2) )
		B_ew(:,m) = B_ew(:,m).*interpCal;
	end;

	amp = 20*log10( sqrt( abs( B_ns ).^2 + abs( B_ew ).^2 ) );
	
	az = atan( abs(B_ew)./abs(B_ns) )*180/pi;

	phaDiff = angle( B_ns ) - angle( B_ew );

	scale = [-25 10];
	minAmp = -5;

	for( k = 1:size( az,1) );
		for( m = 1:size(az,2) );
			if( amp(k,m) <  minAmp)
				az(k,m) = -1000;
				amp(k,m) = -1000;
			end;
			if( (phaDiff(k,m) > 0 & phaDiff(k,m) < 90 ) | ...
				(phaDiff(k,m) > 180 & phaDiff(k,m) < 270 ) | ...
				(phaDiff(k,m) > -180 & phaDiff(k,m) < -90 ) | ...
				(phaDiff(k,m) > -360 & phaDiff(k,m) < -270 )  )
					
			else
				az(k,m) = az(k,m) + 90;
			end;
		end;
	end;

	subplot(2,1,1);
	imagesc(T, F/1e3, amp, scale);
	title(datestr(bbrec.startDate))
	axis xy;
	colorbar;
	ylim([0.50 15]);


	subplot(2,1,2);
	cmap = colormap;
	cmap(1,:) = [0.8 0.8 0.8];
	colormap(cmap);
	imagesc(T, F/1e3, az, [0 180]);
	axis xy;
	colorbar;
	ylim([0.50 15]);

end;

