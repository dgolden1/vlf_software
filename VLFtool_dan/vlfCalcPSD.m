function [p, f] = vlfCalcPSD(numFreq, channel);

global DF;

if( nargin < 1 )
	numFreq = 256;
	channel = 1;
elseif( nargin < 2 )
	channel = 1;
end;


data = DF.bbrec.data(channel,:);

newFs = 24e3;

data = resample( data, newFs, DF.bbrec.sampleFrequency );

data = data - mean(data);

window = numFreq*2;

[p, f] = pwelch( data, window, [], [], newFs );

if( DF.useCal )
    if( channel == 1 )
        interpCal = interp1( DF.cal.f, DF.cal.ns, f );
    else
        interpCal = interp1( DF.cal.f, DF.cal.ew, f );
    end;

    p = (sqrt(p).*interpCal).^2;
end;


