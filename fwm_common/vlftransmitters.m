% The known transmitters
% Magnetic field is from IGRF, at 100 km, rounded to uT.
% http://sidstation.lionelloudet.homedns.org/stations-list-en.xhtml
% sground is ground conductivity in S/m (from FCC web page)

% Hawaii (Lualuahei, HI)
% The conductivity is that of sea water
NPM=struct('name','NPM','f',21400,'P0',424000,...
    'lon',-158.150278,'lat',21.422778,'Bgeo',[5 26 -21]*1e-6,'sground',5);

% Australia (North West Cape, Exmouth, Australia)
NWC=struct('name','NWC','f',19800,'P0',1e6,...
    'lon',114.16556,'lat',-21.81631,'Bgeo',[0 29 42]*1e-6,'sground',0);

% North Dakota (La Moure, ND)
NML=struct('name','NML','f',25200,'P0',233000,...
    'lon',-098.335638,'lat',+46.365990,'Bgeo',[1 16 -51]*1e-6,'sground',30e-3);
