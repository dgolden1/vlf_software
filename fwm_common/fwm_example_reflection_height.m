% Reflection height
loadconstants
global clight impedance0

prof='HAARPwinternight';

hlow=[50:.1:100].';
daytime=0;
% Avoid a jump in active species at 73 km (extrapolate below 73 km):
Nac=getSpecies('O',hlow);
istop=min(find(Nac>0));
hlow(istop)
izero=find(hlow<hlow(istop));
coef=log(Nac(istop+1)/Nac(istop))/(hlow(istop+1)-hlow(istop));
Nac(izero)=Nac(istop)*exp(coef*(hlow(izero)-hlow(istop)));
% Don't forget to convert to cm^{-3}
[Nspec0,S0,specnames]=ionochem_6spec(prof,daytime,hlow,'Nac_profile',Nac/1e6);
Nelow=Nspec0(:,1)*1e6;

hhigh=[100.1:.1:250].';
Nehigh=getNe(hhigh,prof); % in m^{-3}

h=[0 ; hlow ; hhigh];
M=length(h)

Ne=[0 ; Nelow ; Nehigh];
% Ne(1)==0 is important for separating TE and TM waves !!!

farr=[1000:10:5000];
nf=length(farr);
fc=(farr(1:nf-1)+farr(2:nf))/2;
Ei=zeros(2,2,nf);
R=zeros(2,nf);

thi=0;
% Matrix to rotate to x',y'=y,z', z'|| incidence
nx0=sin(thi);
nz0=cos(thi);

for kf=1:nf
    f=farr(kf)
    w=2*pi*f;
    k0=w/clight;
    perm=get_perm(h,w,'Ne',Ne,'Babs',5e-5,'thB',0,'phB',0);
    nz=zeros(4,M); Fext=zeros(6,4,M);
    for k=1:M
        [nz(:,k),Fext(:,:,k)]=fwm_booker(perm(:,:,k),nx0,0);
    end
    F=Fext([1:2 4:5],:,:);
    [Pu,Pd,Ux,Dx,Ruh,Rdl,Rul,Rdh] = fwm_radiation(h*1e3*k0,nz,F,'E=0');
    % - the ground boundary condition is not really needed for Ru{l|h}

    % Reflection coefficient matrix (from the sky) at the ground
    [vv,dd]=eig(Rul(:,:,1)); % extract eigen-modes
    % Provide the continuity
    tmp=diag(dd);
    if kf==1
        ii=[1 2];
    else
        x1=sum(abs(tmp-R(:,kf-1)));
        x2=sum(abs(tmp(2:-1:1)-R(:,kf-1)));
        if x1<x2
            ii=[1 2];
        else
            ii=[2 1];
        end
    end
    % Reflection coefficient (scalar, for 2 eigen-modes)
    R(:,kf)=tmp(ii);
    % The field structure in each eigen-mode
    EHtmp=Fext(:,:,1)*[vv(:,ii);zeros(2,2)];
    % Rotate to the coordinate system connected to the incident ray
    Ei(1,:,kf)=nz0*EHtmp(1,:)-nx0*EHtmp(3,:);
    Ei(2,:,kf)=EHtmp(2,:);
end
Eangle=angle(Ei(1,:,:));
Ei=Ei.*exp(-i*repmat(Eangle,[2 1 1]));

phase=unwrap(angle(R),[],2); %+2*n*pi, where n is unknown
k0=2*pi*farr/clight;
hr=(phase+pi)./(2*repmat(k0,[2 1])*1e3);
hramb=2*pi./(2*repmat(k0,[2 1])*1e3); % ambiguity
figure; plot(farr/1e3,hr);
%hold on; plot(farr/1e3,hr-hramb); plot(farr/1e3,hr+hramb); hold off

figure; plot(farr/1e3,abs(R));
% Resonances
figure; plot(farr/1e3,1./abs(R+1));

figure; plot(farr/1e3,abs(squeeze(Ei(1,:,:))));
hold on; plot(farr/1e3,abs(squeeze(Ei(2,:,:))),'--'); hold off;
Eyphase=squeeze(angle(Ei(2,:,:)));
figure; plot(farr/1e3,unwrap(Eyphase,[],2));
