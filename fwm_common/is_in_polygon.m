function topol=is_in_polygon(x0,y0,xb,yb)
% Number of counterclockwise winds of boundary (xb,yb) around the point
% (x,y).
% Adopted from my earlier IDL function with the same name

% Confirm that the region is an island
n=length(xb);
if length(yb)~=n
    error('polygon is not valid');
end
if(xb(1)~=xb(n) | yb(1)~=yb(n))
    xb(n+1)=xb(1);
    yb(n+1)=yb(1);
end
% Use topology to determine wether we are inside.
x=xb-x0;
y=yb-y0;
% Azimuthal angles
% az=atan2(y,x)
% Count discontinuities
% If there is an odd number of discontinuities, we are inside.
daz=diff(atan2(y,x))/pi;
% A faster way (?) - no arctangents.
% daz=diff(myatan(y,x))/4.;
ind=find(abs(daz)>1);
topol=sum(sign(daz(ind)));

function t=myatan(y,x)
% Pedestrian's arctangent - enough for topological purposes.
% Note that pi == 4
% Skew quadrant
t=x; % copy the size
ind1=find(abs(y) <= abs(x));
ind2=find(abs(y) > abs(x));
t(ind1)=-2*sign(x(ind1))+2+y(ind1)/x(ind1);
t(ind2)=2*sign(y(ind2))-x(ind2)/y(ind2);
