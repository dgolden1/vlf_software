function result=fwm_aux(np_arg,phitry,z,eground,perm,nx0,ny0,ksa,I0,kia,dzl,dzh)
% The wrapper for FWM_FIELD passed as an argument for BESTGRID
% I0 has size 3 x Ms x Nnx0 x Nny0 or 3 x Ms x Nnp0 or 3 x Ms

output_interval=20;
if isempty(ny0)
    % We ignore given phitry
    phitry=[0];
    if ~isempty(nx0)
        % To size Nnp0 x 3 x Ms
        I0p=permute(I0,[3 1 2]);
    end
else
    % To size Nnx0 x Nny0 x 3 x Ms
    I0p=permute(I0,[3 4 1 2]);
end
Nnp=length(np_arg);
Nphitry=length(phitry);
Ms=length(ksa);
Mi=length(kia);
EHf=zeros(6,Nnp,Mi,Nphitry);
I0i=zeros(3,Ms,Nnp);
tstart=now*24*3600; toutput=tstart;
for iphitry=1:Nphitry
    disp(['Trying angle ' num2str(phitry(iphitry)*180/pi) ' deg (' ...
        num2str(iphitry) ' of ' num2str(Nphitry) ')']);
    nx=np_arg*cos(phitry(iphitry));
    ny=np_arg*sin(phitry(iphitry));
    % The current - interpolate
    % Note that we cannot use multidimensional interpolation with interp2,
    % hence the cycle.
    if isempty(ny0)
        if isempty(nx0)
            % Point source - just repeat the matrix I0
            I0i=repmat(I0,[1 1 Nnp]);
        else
            % We have an axisymmetric case
            I0i=interp1(nx0,I0p,nx); % phitry==0
        end
    else
        % Full 3D case
        for c=1:3
            for ks=1:Ms
                I0i(c,ks,:)=interp2(nx0,ny0,I0p(:,:,c,ks),nx,ny);
            end
        end
    end
    EHf(:,:,:,iphitry)=fwm_field(z,eground,perm,nx,ny,ksa,I0i,kia,dzl,dzh);
    timec=now*24*3600;
    ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        disp(['Done=' num2str(iphitry/Nphitry*100) '%; ' ...
            'Time=' hms(ttot) ...
            ', ETA=' hms(ttot/iphitry*(Nphitry-iphitry))]);
    end
end
% Move the grid argument (in this case, np) to the first position.
result=permute(EHf,[2 1 3 4]);
