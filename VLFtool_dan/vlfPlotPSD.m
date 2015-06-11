function vlfPlotPSD( scale ); 

if( nargin < 1 )
	scale = -1;
end;

global DF;

tag = 'psd';

myfig = findobj('Tag', tag );
if ( isempty( myfig ) )
	myfig = figure;
    set( myfig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'inches', 'Tag', tag);
end;
figure(myfig);

clf;

vlfpsd = 10*log10( DF.VLF.psd ./ (1/100e3) );
if( length( scale ) == 1 )
	imagesc( DF.VLF.UT, DF.VLF.freq/1e3, vlfpsd );
else
	imagesc( DF.VLF.UT, DF.VLF.freq/1e3, vlfpsd, scale );
end;
h_ax = gca;

h_cb = colorbar;
axes( h_cb );
title('dB');
if( DF.useCal )
	ylabel( 'wrt 10^{-29} T^2 Hz^{-1}' );
else
	ylabel('uncal');
end;

axes( h_ax );
datetick('x', 'keeplimits');
axis xy;

ylabel('Freq, kHz');

title( [DF.bbrec.site ' Power Spectral Density ' ...
	datestr(DF.VLF.UT(1), 26) ' - '  datestr(DF.VLF.UT(end),26) ] );


