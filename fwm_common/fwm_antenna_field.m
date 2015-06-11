function EHf=fwm_antenna_field(zd,eground,perm,nx,ny,Mi)
if nargin<6
    % Only satellite
    Mi=1;
    % If Mi==2, it means do also ground
end
M=length(zd);
if Mi==1
    ilayers=[M]; dzl=[0]; dzh=[nan];
elseif Mi==2
    % Notice that the order is inverted: first sat, then ground
    ilayers=[M 1]; dzl=[0 0]; dzh=[nan zd(2)];
end
slayers=[1];
Ms=length(slayers);
Nnp=length(nx);
I=repmat([0;0;1],[1 Ms Nnp]);
EHf=fwm_field(zd,eground,perm,nx,ny,slayers,I,ilayers,dzl,dzh);
