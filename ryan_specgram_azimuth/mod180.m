function out = mod180(in,varargin);
%syntax: out = mod180(in,theta0);
%
%out is in modulo 180, with the range centered on theta0 (all numbers in
%degrees).  If theta0 is omitted, the center of the range defaults to 0.  

if(nargin>1)
    theta0 = varargin{1};
else
    theta0 = 0;
end

out = mod(in+90-theta0,180)-90+theta0;
