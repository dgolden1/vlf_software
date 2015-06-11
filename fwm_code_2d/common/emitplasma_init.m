% Before calling this, the following should be given:
%   h,w,Nx,Ny,dx,dy
% Preliminaries for emitplasma_example
global global_dir ech me eps0 clight impedance0
if isempty(ech)
    loadconstants
end

z=1e3*h.'; % row
M=length(h)
k0=w/clight;
zdim=k0*z;
if ~given_perm
    if ~given_Ne
        Ne=getNe(h,'HAARPwinternight');
    end
    if ~given_nu
        nu=plot_collisionrate(h,'doplot',0);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The variable B, in T
    if ~given_Bgeo
        [Bgeo,Babs,thB,phB]=get_Bgeo(h,'Bgeo_load','default');
    end
    % Gyrofrequency
    wH=ech*Babs/me;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Permittivity components
    
    wp2=Ne*ech^2/(me*eps0);
    R=1-wp2./w./(w+i*nu-wH);
    L=1-wp2./w./(w+i*nu+wH);
    S=(R+L)/2;
    D=(R-L)/2;
    P=1-wp2./w./(w+i*nu);
    isvacuum=(Ne==0);
    perm=zeros(3,3,M);
    for iz=1:M
        perm(:,:,iz)=rotated_perm(S(iz),P(iz),D(iz),thB(iz),phB(iz));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The horizontal coordinate/refractive index mesh
x=[1-Nx/2:Nx/2]*dx;
y=[1-Ny/2:Ny/2]*dy;
nx=2*pi*[1-Nx/2:Nx/2]*(1/(dx*k0*Nx)); % the refraction coef
ny=2*pi*[1-Ny/2:Ny/2]*(1/(dy*k0*Ny)); % the refraction coef
% For Fourier transforms: useful indeces for shifting.
indx=[Nx/2:Nx 1:Nx/2-1];
indy=[Ny/2:Ny 1:Ny/2-1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save it to recall faster later
if ~given_perm
    permvars=' Ne nu S D P wp2 wH ';
    eval(['save ' datadir 'Bgeo wH thB phB Bgeo Babs']);
else
    permvars='';
end
eval(['save ' datadir 'common ' permvars ' M Nx Ny dx dy x y z nx ny h ' ...
    ' perm isvacuum k0 w indx indy']);
