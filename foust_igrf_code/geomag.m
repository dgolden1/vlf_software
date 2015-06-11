function [field_intensity,declination,inclination,horizontal,x_northward,y_eastward,z_vertical] = geomag(year, month, day, altitude, latitude,longitude);
%
% Interface to the IGRF10 earth magnetic model
%
% [ field_intensity,declination,inclination,horizontal,x_northward, ...
%   y_eastward,z_vertical ] = geomag( year, month, day, altitude, ...
%                                     latitude,longitude );
%
%   Inputs:
%     year       - year (1900-2010)
%     month      - month (1-12)
%     day        - day of month (1-...)
%     altitude   - WGS84 altitude above mean sea level
%     latitude   - latitude, + = north, - = south, degrees
%     longitude  - longitude, + = east, - = west, degrees
%
%   Outputs:
%     field_intensity - magnitude of B, nT
%     declination     - declination of field from geographic north, degrees
%     inclination     - inclination of magnetic field, degrees
%     horizontal      - Horizontal intensity, nT
%     x_northward     - Northward component of magnetic field, nT
%     y_eastward      - Eastward component of magnetic field, nT
%     z_vertical      - Vertically-downward component of magnetic field, nT

%geomag_dir = dirname('geomag60');
geomag_dir = fileparts(which('geomag60'));
if( isunix == 0 )
 geomag_dir = [geomag_dir '\'];
else
 geomag_dir = [geomag_dir '/'];
end;

if( altitude < 0 )
 altitude = 0;
end
[field_intensity,declination,inclination,horizontal,x_northward,y_eastward,z_vertical] = geomag60(year, month, day, altitude, latitude,longitude,geomag_dir);
