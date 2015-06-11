function [EH,EHsave]=fwm_assemble(k0,nx,ny,da,EHf,coorrperp,rperp1,rperp2,bkp_file)
%FWM_ASSEMBLE Inverse Fourier transform from the polar mesh
% It is much slower than FFT
% Usage:
%    EH=fwm_assemble(k0,nx,ny,da,EHf,x,y);
% Inputs:
% Outputs:
%    EH (6 x Ms x {Nx|Nr} x {Ny|Nphi|Nh})
% Author: Nikolai G. Lehtinen

switch coorrperp
	case 1
		% Cartesian coordinate output
		EH=fwm_assemble_xy(k0,nx,ny,da,EHf,1e3*rperp1,1e3*rperp2,bkp_file);
	case 2
		% Polar coordinate output
		EH=fwm_assemble_rp(k0,nx,ny,da,EHf,1e3*rperp1,rperp2,bkp_file);
	case 3
		% Harmonics coordinate output
		r=1e3*rperp1; m=rperp2;
		% Determine the value of Nphimax
		np=sqrt(nx.^2+ny.^2);
		npmax=max(np);
		Nphimax=sum(abs(np-npmax)<100*eps);
		phi=[0:Nphimax-1]*2*pi/Nphimax;
		EH=fwm_assemble_rp(k0,nx,ny,da,EHf,r,phi,bkp_file);
		if nargout>1
			EHsave=EH;
		end
		% To EH+-
		EHx=EH([1 4],:,:,:);
		EH([1 4],:,:,:)=EHx+i*EH([2 5],:,:,:);
		EH([2 5],:,:,:)=EHx-i*EH([2 5],:,:,:);
		EH=fft(EH,[],4)/Nphimax;
		% Take into account that EH+ == const corresponds to m==-1 etc.
		EH([1 4],:,:,:)=circshift(EH([1 4],:,:,:),[0 0 0 -1]);
		EH([2 5],:,:,:)=circshift(EH([2 5],:,:,:),[0 0 0 1]);
		% Select only the needed m
		if length(m)<Nphimax & nargout==1
			disp('Warning: discarding some information');
		end
		EH=EH(:,:,:,mod(m-1,Nphimax)+1);
	otherwise
		error(['unknown option: coorrperp=' num2str(coorrperp)]);
end
