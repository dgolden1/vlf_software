% A script to calculate emission from a ground-based vertical dipole
% antenna using the full-wave method
tstart_total=now*24*3600;
if do_axisymmetric
    disp('***** Starting a 2D (axisymmetric) calculation *****');
else
    disp('***** Starting a 3D calculation *****');
end
disp('***** Load various parameters *****');
fwm_antenna_parameters

if do_axisymmetric & do_new_axisymmetric
    % The new method
    hext=[h(1);0.001;h(2:end)];
    Mext=length(hext);
    permext=zeros(3,3,Mext);
    permext(:,:,2:Mext)=perm;
    permext(:,:,1)=eye(3);
    ksa=[2];
    I0=[0;0;impedance0*Iscaled]; nx0=[]; m=0;
    if Mi==1
        hi=[hext(Mext)];
    elseif Mi==2
        hi=[0 hext(Mext)];
    else
        error('unexpected Mi');
    end
    if sground~=0
        eground=1+i*sground/(w*eps0)
    else
        eground=ground_bc
    end
    [EH,nx,EHf]=fwm_axisymmetric(f,hext,permext,eground,ksa,nx0,I0,m,x/1e3,hi,[],retol);
end

if ~(do_axisymmetric & do_new_axisymmetric)
    disp('***** Calculate the best grid *****');
    % Try restoring the grid from backup
    if exist([datadir 'grid.mat'],'file')
        load([datadir 'grid']);
        disp('----- Loaded grid data -----');
    else
        % No backup, have to calculate the best grid
        fwm_antenna_bestgrid
    end
end
if do_axisymmetric
    if ~do_new_axisymmetric
        fwm_antenna_2d
    end
else
    fwm_antenna_3d_waves
    fwm_antenna_3d_assemble
    fwm_antenna_3d_plotting
end
t_total=now*24*3600-tstart_total;
disp(['**** TOTAL TIME = ' hms(t_total) ' ****']);
