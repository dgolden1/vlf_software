function cres=conducne(en,ne,Nm,Ne,wH,w,needed,doapprox)
%cres=conducne(en,ne,Nm,Ne,wH,w,needed,doapprox)
% Conductivity for given Ne
% ne does not have to be normalized.
global ech me
if isempty(ech)
    loadconstants
end
if nargin<8
    doapprox=0;
end
n=length(needed);
cres=zeros(n,1);

% Catch the zero Ne case
if Ne<0 | isnan(Ne)
    error(['Ne=' num2str(Ne)]);
elseif Ne==0
    return
end

nen=length(en);
den=en(nen)/nen;
ec=0.5*(en(1:nen-1)+en(2:nen));
nc=0.5*(ne(1:nen-1)+ne(2:nen));
dn=(ne(2:nen)-ne(1:nen-1))/den;
if doapprox
    numom=Nm*getnumom(en);
    distr=ne/sum(ne);
else
    numom=Nm*getnumom(ec);
    distr=-2/3*(ec.*dn-nc/2)/sum(nc);
end
c=zeros(1,3);
for imode=-1:1
    c(imode+2)=Ne*ech^2/me*sum(distr./(numom-i*(w+imode*wH)));
end
for k=1:n
    switch needed(k)
        case 'x'
            cres(k)=c(1);
        case 'o'
            cres(k)=c(3);
        case 'z'
            cres(k)=c(2);
        case 'p'
            cres(k)=(c(1)+c(3))/2;
        case 'h'
            cres(k)=i*(c(1)-c(3))/2;
    end
end
