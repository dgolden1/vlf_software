function result=fwm_bestgrid(np_arg,phitry,zd,eground,perm,...
    ksa,coornperp,nperp1,nperp2,I0,...
    kia,dzl,dzh)
% The wrapper for FWM_FIELD passed as an argument for BESTGRID
% Version 2: better handling of I0 given by harmonics
global output_interval
do_output=~isempty(output_interval);

point_source=isempty(nperp1)
Nnp=length(np_arg);
Nphitry=length(phitry);
Ms=length(ksa);
Mi=length(kia);
switch coornperp
	case 1
		nx0=nperp1; ny0=nperp2;
	case 2
		np0=nperp1; phin0=nperp2;
	case 3
		np0=arg1; m0=nperp2;
		% I0 has size 6 x Ms x Nnp0 x Nh or 6 x Ms x Nnp0 or 6 x Ms
		% For axisymmetric case, we must have m of length 1
		% But the reverse is not true.
		Nh=length(m0);
	otherwise
		error('unknown coornperp');
end

if point_source
    % Point source, for both cartesian and harmonics cases
    I0i=repmat(I0,[1 1 Nnp]);
else
    switch coornperp
		case 1
			% To size Nny0 x Nnx0 x 6 x Ms
			% Note that we switched x<->y
			I0p=permute(I0,[4 3 1 2]);
			I0i=zeros(6,Ms,Nnp); % Initialize
		case 2
			error('not impemented');
		case 3
			% To size Nnp0 x 3 x Ms x Nh and back to 3 x Ms x Nnp x Nh
			I0p=permute(interp1(np0,permute(I0,[3 1 2 4]),np_arg),[2 3 1 4]);
		otherwise
			error('unknown coornperp');
	end
end

EHf=zeros(6,Mi,Nnp,Nphitry);
tstart=now*24*3600; toutput=tstart;
for iphitry=1:Nphitry
    disp(['Trying angle ' num2str(phitry(iphitry)*180/pi) ' deg (' ...
        num2str(iphitry) ' of ' num2str(Nphitry) ')']);
    phi=phitry(iphitry);
    nx=np_arg*cos(phi);
    ny=np_arg*sin(phi);
    % The current - interpolate
    if ~point_source
        switch coornperp
			case 1
				% Full 3D case
				for c=1:6
					for ks=1:Ms
						I0i(c,ks,:)=interp2(nx0,ny0,I0p(:,:,c,ks),nx,ny);
                    end
				end
			case 2
				error('not implemented');
			case 3
				e=permute(repmat(exp(i*m(:)*phi),[1 6 Ms Nnp]),[2 3 4 1]);
				I0i=sum(e.*I0p,4);
			otherwise
				error('unknown coornperp')
        end
    end
    EHf(:,:,:,iphitry)=fwm_field(zd,eground,perm,...
        ksa,nx,ny,I0i,kia,dzl,dzh);
    timec=now*24*3600;
    ttot=timec-tstart;
    if do_output
        if timec-toutput>output_interval
            toutput=timec;
            disp(['Done=' num2str(iphitry/Nphitry*100) '%; ' ...
                'Time=' hms(ttot) ...
                ', ETA=' hms(ttot/iphitry*(Nphitry-iphitry))]);
        end
    end
end
% Move the grid argument (in this case, np) to the first position.
result=permute(EHf,[3 1 2 4]);
