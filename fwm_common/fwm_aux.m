function result=fwm_aux(np_arg,phitry,z,eground,perm,...
    ksa,cartesian,arg1,arg2,I0,...
    kia,dzl,dzh)
% The wrapper for FWM_FIELD passed as an argument for BESTGRID
global output_interval
do_output=~isempty(output_interval);

point_source=isempty(arg1);
Nnp=length(np_arg);
Nphitry=length(phitry);
Ms=length(ksa);
Mi=length(kia);
if cartesian
    nx0=arg1; ny0=arg2;
    % Empty ny0 indicates an axisymmetric problem
    axisymmetric=isempty(ny0);
else
    np0=arg1; m=arg2;
    % I0 has size 3 x Ms x Nnp0 x Nh or 3 x Ms x Nnp0 or 3 x Ms
    % For axisymmetric case, we must have m of length 1
    % But the reverse is not true.
    Nh=length(m);
end

if point_source
    % Point source, for both cartesian and harmonics cases
    I0i=repmat(I0,[1 1 Nnp]);
else
    if cartesian
        if axisymmetric
            % To size Nnp0 x 3 x Ms
            I0p=permute(I0,[3 1 2]);
        else
            % To size Nny0 x Nnx0 x 3 x Ms
            % Note that we switched x<->y
            I0p=permute(I0,[4 3 1 2]);
            I0i=zeros(3,Ms,Nnp);
        end
    else
        % To size Nnp0 x 3 x Ms x Nh and back to 3 x Ms x Nnp x Nh
        I0p=permute(interp1(np0,permute(I0,[3 1 2 4]),np_arg),[2 3 1 4]);
    end
end

EHf=zeros(6,Nnp,Mi,Nphitry);
tstart=now*24*3600; toutput=tstart;
for iphitry=1:Nphitry
    disp(['Trying angle ' num2str(phitry(iphitry)*180/pi) ' deg (' ...
        num2str(iphitry) ' of ' num2str(Nphitry) ')']);
    phi=phitry(iphitry);
    nx=np_arg*cos(phi);
    ny=np_arg*sin(phi);
    % The current - interpolate
    if ~point_source
        if cartesian
            if axisymmetric
                % We have an axisymmetric case
                I0i=permute(interp1(nx0,I0p,np_arg),[2 3 1]);
            else
                % Full 3D case
                for c=1:3
                    for ks=1:Ms
                        I0i(c,ks,:)=interp2(nx0,ny0,I0p(:,:,c,ks),nx,ny);
                    end
                end
            end
        else
            e=permute(repmat(exp(i*m(:)*phi),[1 3 Ms Nnp]),[2 3 4 1]);
            I0i=sum(e.*I0p,4);
        end
    end
    EHf(:,:,:,iphitry)=fwm_field1(z,eground,perm,nx,ny,ksa,I0i,kia,dzl,dzh);
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
result=permute(EHf,[2 1 3 4]);
