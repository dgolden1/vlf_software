function eqeuv = euvReadEqDat( fitsFile, fitsPath, cal, mask )

if( nargin < 3 )
	cal = 1;
        mask = 1;
end;

yyyy = str2num( fitsFile(2:5) );
ddd = str2num( fitsFile(6:8) );
hh = str2num( fitsFile(9:10) );
mm = str2num( fitsFile(11:12) );

eqeuv.UT = datenum( yyyy, 0, ddd, hh, mm, 0 );


eqeuv.image = fitsread( [fitsPath fitsFile]);
eqeuv.image = eqeuv.image(end:-1:1, end:-1:1 );

eqeuv.header = fitsinfo( [fitsPath fitsFile]);

eqeuv.maxL = eqeuv.header.PrimaryData.Keywords{7,2};

eqeuv.x = linspace( -eqeuv.maxL, eqeuv.maxL, length(eqeuv.image) );
eqeuv.y = linspace( -eqeuv.maxL, eqeuv.maxL, length(eqeuv.image) );

if( cal )
	eqeuv = euvCalibration( eqeuv );
end;

if( mask )
  load('mask.mat');
  eqeuv.image = eqeuv.image .* mask;
end;
