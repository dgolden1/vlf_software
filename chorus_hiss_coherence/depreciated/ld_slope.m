function [a,e] = ld_slope(x,y)
%syntax: [a,e] = ld_slope(x,y)
%Gives slope by minimizing L-2 distance from point to line through origin
% a=slope
% e = mmse
%Ryan Said, 3/17/06

% $Id$

alpha = (norm(y)^2 - norm(x)^2)/(2*y(:)'*x(:)+eps);
a1 = alpha + sqrt(1+alpha^2);
a2 = alpha - sqrt(1+alpha^2);

%one gives minimum error, one gives maximum error (orthogonal slopes)
%test both:

e1 = sum((y-a1*x).^2/(1+a1^2));
e2 = sum((y-a2*x).^2/(1+a2^2));

if(e1 < e2)
    a = a1;
    e = e1;
else
    a = a2;
    e = e2;
end
