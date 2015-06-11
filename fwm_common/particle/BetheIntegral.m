function res=BetheIntegral(m,n,p,a,b,cosab)
% Integral (1/4*pi) \int d\Omega q^{-2m}(E-p_\parallel)^{-n}
% Based on
% Gluckstern and Hall (1953), doi:10.1103/PhysRev.90.1030
% Only for cases {0,1},{1,0},{0,2},{2,0},{1,1},{1,2},{2,1},{2,-1}
didswap=0;
if m<n
    % Switch the places
    didswap=1;
    [m,n]=swap(m,n);
    [a,b]=swap(a,b);
end
% Now m>=n

res=0;
switch m
    case 1
        switch n
            case 0
                res=log((1+p.*a)./(1-p.*a))./(p.*a);
            case 1
            otherwise
                error(m,n,didswap);
        end
    case 2
        switch n
            case -1
                t=b.*cosab./a;
                res=t.*IGHmn(1,0,p,a,b,cosab)+(1-t).*IGHmn(2,0,p,a,b,cosab);
            case 0
                res=2./(1-p.^2.*a.^2);
            case 1
            case 2
            otherwise
                error(m,n,didswap);
        end
    otherwise
         error(m,n,didswap);       
end

function [b,a]=swap(a,b)
return

function errormn(m,n,didswap)
if didswap
    [m,n]=swap(m,n);
end
error(['m=' num2str(m) ', n=' num2str(n)]);
