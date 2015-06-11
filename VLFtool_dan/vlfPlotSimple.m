

startSec = 0;
endSec = 5;

%[filename,pathname] = uigetfile('*.mat', 'Choose a BB file to load');
filename = 'II050422210500_002.mat';
pathname = '/mnt/cdrom1/';

bb = vlfExtractBB( pathname, filename, startSec, endSec );
if( bb.nChannels > 1 )
	data = bb.data(1,:) - mean(bb.data(1,:));
else
	data = bb.data - mean(bb.data);
end;

nfft = 1024;
window = 512;
noverlap = 256;

[B, F, T] = specgram( data, nfft, bb.sampleFrequency, ...
	window, noverlap );

B = 20*log10(abs(B));


maxB = mean( max( B ) );
minB = maxB - 40;

imagesc( T, F/1e3, B, [minB maxB] );
axis xy;

ylabel('Freq, kHz');
xlabel('Time, s');
title( [bb.site ' ' datestr( bb.startDate, 'dd mmm yyyy HH:MM:SS' ) ] );

set(gca, 'TickDir', 'out');

colorbar;



