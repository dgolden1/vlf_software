function [h,Ne,Nm,T0]=get_environment(options)
% T0 is in eV!
global kB ech
if isempty(kB)
    loadconstants
end
h=getvaluefromdict(options,'h',[]);
if isempty(h)
    hstart=getvaluefromdict(options,'hstart',60);
    hfinish=getvaluefromdict(options,'hfinish',120);
    dh=getvaluefromdict(options,'dh',2);
    h=[hstart:dh:hfinish];
    nh=length(h);
else
    hstart=h(1); nh=length(h); hfinish=h(nh); dh=h(2)-h(1);
end


% Electron density profile
NeProfile=getvaluefromdict(options,'NeProfile','');
if strcmp(NeProfile,'')
    Ne=getvaluefromdict(options,'Ne',[]);
else
    Ne=getNe(h,NeProfile);
end
if isempty(Ne)
    error('Ne is not given')
elseif any(size(Ne)~=size(h))
    error(['Ne(' num2str(size(Ne)) ') is of different size than h(' ...
        num2str(size(h)) ')']);
end

% Constants
Nm=getvaluefromdict(options,'Nm',getNm(h));
T0=getvaluefromdict(options,'T0',getTn(h)*kB/ech);
