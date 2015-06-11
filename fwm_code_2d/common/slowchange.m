function ii=slowchange(x,e)
%SLOWCHANGE
% function ii=slowchange(x,e)
% Find the minimal number of points so that the given array changes only by
% a fraction of e from point to point.

% x is a column matrix
[n,m]=size(x);
if n==1
    x=x(:); n=length(x);
end

c=1; k=1;
ii(c)=k;
while k<n
    kk=k+1;
    for kk=k:n
        if any(x(k,:)==0 & x(kk,:)~=0)
            break
        end
        inz=find(x(k,:)~=0);
        if any(abs(x(kk,inz)./x(k,inz)-1) > e)
            break
        end
    end
    c=c+1;
    k=kk;
    ii(c)=k;
end
