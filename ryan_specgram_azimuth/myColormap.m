function h = myColormap(varargin);
%
%options: 'mag','magWithWhite','azimuth'

if(nargin==0)
    colorType = 'magWithWhite';
else
    colorType = varargin{1};
end

switch colorType
    case 'mag'
        h = jet(64);
    case 'magWithWhite'
        h = [[1,1,1];jet(64)];
    case 'azimuth'
        h = [1,1,1;hsv(180)];
    otherwise
        warning('colormap not recognized, reverting to jet colormap');
        h = jet(64); %set as default if argument not recognized
end
