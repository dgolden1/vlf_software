function [ul,dh,uh,dl,Ruh,Rdl,Rul,Rdh]=...
    fwm_radiation(zd,nz,F,ground_bc,layers,DEH,uli,dli)
% FWM_RADIATION Full-wave model or radiation or propagation
% This version can only calculate radiation by sheet currents at boundaries
% between layers.
% Description: Lehtinen and Inan [2008], doi:10.1029/2007JA012911
% DOI link: http://dx.doi.org/10.1029/2007JA012911
% -----
% Usage
% -----
% For wave generation by current sources (found by FWM_DEH):
%    [ul,dh] = fwm_radiation(zd,nz,F,ground_bc,layers,DEH);
% For wave propagation:
%    [ul,dh] = fwm_radiation(zd,nz,F,ground_bc,[],[],uli,dli);
% After that, find "ud" vector at any point using FWM_INTERMEDIATE, and
% convert to E,H fields by "Fext" matrix
% Advanced usage for wave propagation (gives same result as above):
%    [Pu,Pd,Ux,Dx,Ruh,Rdl] = fwm_radiation(zd,nz,F,ground_bc);
%    ul=zeros(2,M); dh=zeros(2,M-1);
%    % For propagation up:
%    ul(:,1)=uli; % [1;0] for TE wave; [0;1] for TM wave
%    for k=1:M-1
%       uh=Pu(:,:,k)*ul(:,k);
%       ul(:,k+1)=Ux(:,:,k)*uh;
%       dh(:,k)=Ruh(:,:,k)*uh;
%    end
%    % Or, for propagation down:
%    dli=[1;0]; % whistler wave
%    ul(:,M)=Rdl(:,:,M)*dli;
%    dl=dli;
%    for k=M-1:-1:1
%       dh(:,k)=Dx(:,:,k)*dl; % dh in layer k
%       dl=Pd(:,:,k)*dh(:,k); % dl in layer k
%       ul(:,k)=Rdl(:,:,k)*dl;
%    end
% More usage examples (with an extended output list):
%    [ul,dh,uh,dl]=fwm_radiation(zd,nz,F,ground_bc,layers,DEH);
%    udl=cat(1,ul,dl); udh=cat(1,uh,dh);
% or
%    [Pu,Pd,Ux,Dx,Ruh,Rdl,Rul,Rdh] = fwm_radiation(z,nz,F,ground_bc);
% ------------------
% Inputs and outputs
% ------------------
% The index corresponding to the dimension of size {M|M-1} is denoted k,
% and to dimension of size Ms is denoted ks.
% Input:
%    zd (M) - dimensionless altitudes, zd=k0*z, k0=w/c, usually with
%       zd(1)==0 corresponding to the ground; corresponds to the
%       {lower|upper} boundary of layer {k|k-1}
%    nz (4 x M) - vertical refractive index in layer k, for 4 modes sorted
%       by decreasing imaginary part, so that the first two values
%       correspond to upward modes u=[u(1);u(2)] and the second two to
%       downward modes d=[d(1);d(2)]
%    F (4 x 4 x M) - mode structure in layer k, i.e. the matrix to convert
%       the wave variables ud=[u(1);u(2);d(1);d(2)] which correspond to nz
%       described above, to fields EH=[Ex;Ey;Hx;Hy]
%    ground_bc - boundary condition at z(1); possible values =
%       'E=0', 'H=0' or 'free'; one can also specify a 2x2 reflection
%       coefficient matrix Rground (computed by FWM_RGROUND).
% nz and F can correspond, e.g., to a wave with a horizontal wave vector
% (kx,ky)=k0*(nx,ny) (fixed due to Snell's law). Then nz and F are found
% by solving the Booker equation with SOLVE_BOOKER_3D. F is a submatrix
% F=Fext([1:2 4:5],:) of Fext returned by SOLVE_BOOKER_3D.
% Optional inputs (the sources):
%    layers (Ms) - layer numbers k=layers(ks) corresponding to the sources
%    DEH (4 x Ms) - sources [DEx;DEy;DHx;DHy] at the boundaries between
%       layers; the sources are assumed to be surface currents flowing in
%       the plane just above boundary z(k), in layer k==layers(ks). These
%       are found from given surface currents by using FWM_DEH.
% Optional inputs (initial waves at lower and higher boundary):
%    {u|d}li (2 x 1) - {up|down} wave just above {z(1)|z(M)}, default=[0;0]
%       (given also by an empty matrix)
%    Note that the {lower|upper} boundary condition is ignored for the
%    field due to {u|d}li. If there are also nonzero sources, this leads to
%    a mixup in the boundary conditions -- avoid such situations.
% Outputs:
%    {u|d}{l|h} (2 x {M|M-1}) - {up|down} mode amplitudes at {low|high}
%       boundaries of layer k
% Advanced outputs:
%    P{u|d} (2 x 2 x M-1) - {up|down} propagators inside layer k
%    {U|D}x (2 x 2 x M-1) - {up|down} propagators across boundary z(k+1)
%    R{u|d}{l|h} (2 x 2 x {M|M-1}) - reflection coefficient for {up|down}
%       mode at the {low|high} boundary of layer k
% The size is {M|M-1} if we consider {low|high} boundaries of layers,
% which is indicated by letter {l|h} in the notation. There is no high
% boundary of the last infinite layer M.
% IMPORTANT NOTES:
%    1. For complex amplitudes, we use the physics convention:
%       E,H ~ e^{-iwt}
%    2. We use the Budden normalized magnetic field H=Z0*H_SI, where
%       Z0=sqrt(mu0/eps0) is the impedance of free space.
% See also: FWM_DEH, FWM_INTERMEDIATE, SOLVE_BOOKER_3D.
% Previously used (and still working!): REFLECTPLASMA
% Author: Nikolai G. Lehtinen

output_matrices=(nargin<5);
if output_matrices
    layers=[];
end
if nargin==5
    error('DEH is not given');
end
if nargin<4
    ground_bc='E=0';
end
if nargin<8
    dli=[];
end
if nargin<7
    uli=[];
end
if ~output_matrices
    need_propagation_up=~(isempty(layers) & isempty(uli));
    need_propagation_down=~(isempty(layers) & isempty(dli));
else
    need_propagation_up=1;
    need_propagation_down=1;
end
if ~need_propagation_down
    ground_bc='not_used';
end

M=length(zd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The matrices for transporting (u,d) through a slab z(k)<z<z(k+1), k=1:M-1
dz=diff(zd); % dimensionless=k0*h
kh=nz(:,1:M-1).*repmat(dz(:).',4,1);
kh(3:4,:)=-kh(3:4,:); % so that imag(kh)>0
Ep=exp(i*kh);
% Transporting up (|Pu|<=1)
Pu=zeros(2,2,M-1); Pu(1,1,:)=Ep(1,:); Pu(2,2,:)=Ep(2,:);
% Note that for evanescent waves, |Pu|<=1
% Transporting down (|Pd|<=1)
Pd=zeros(2,2,M-1); Pd(1,1,:)=Ep(3,:); Pd(2,2,:)=Ep(4,:);
% The matrix for transporting (u,d) across a boundary at z(k+1), k=1:M-1
Tu=zeros(4,4,M-1); Td=zeros(4,4,M-1);
for k=1:M-1
    % Please note that T{u,d}(k) corresponds to boundary z(k+1). There is
    % no transport through z(1).
    % Up (from z(k+1)-0 to z(k+1)+0)
    Tu(:,:,k)=F(:,:,k+1)\F(:,:,k);
    if ~isempty(find(isnan(Tu(:,:,k))))
        error(['k=' num2str(k) ': Tu']);
    end
    % Down (just an inverse)
    Td(:,:,k)=F(:,:,k)\F(:,:,k+1);
    if ~isempty(find(isnan(Td(:,:,k))))
        z(k)
        nz(:,k)
        F(:,:,k)
        error(['k=' num2str(k) ': Td']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reflection coefficients
% Reflection from above
Rul=zeros(2,2,M);
Ruh=zeros(2,2,M-1);
if need_propagation_up | output_matrices
    %Rul(:,:,M)=zeros(2,2); % no reflection
    % There is no R{u,d}h(:,:,M) because layer M has no upper boundary.
    for k=M-1:-1:1
        Ruh(:,:,k)=(Td(3:4,1:2,k)+Td(3:4,3:4,k)*Rul(:,:,k+1))/ ...
            (Td(1:2,1:2,k)+Td(1:2,3:4,k)*Rul(:,:,k+1));
        Rul(:,:,k)=Pd(:,:,k)*Ruh(:,:,k)*Pu(:,:,k);
    end
end
% Reflection from below
Rdl=zeros(2,2,M);
Rdh=zeros(2,2,M-1);
if need_propagation_down | output_matrices
    % Rground is given by key 'ground_bc':
    if ischar(ground_bc)
        switch ground_bc
            case 'free'
                Rground=zeros(2,2);
            case {'default','E=0'}
                Rground=-eye(2); % for E=0 at z(1) (superconducting ground)
                % More generally,
                %   Rground=-inv(F(1:2,1:2,1))*F(1:2,3:4,1)
                % but in vacuum this simplifies to the above expression.
            case 'H=0'
                Rground=eye(2); % for H=0 at z(1) (hypothetical situation)
            otherwise
                error('unknown boundary condition')
        end
    else
        % We assume that it was computed by fwm_Rground
        % and passed here as a 2x2 matrix
        Rground=ground_bc;
    end
    Rdl(:,:,1)=Rground;
    for k=1:M-1
        Rdh(:,:,k)=Pu(:,:,k)*Rdl(:,:,k)*Pd(:,:,k);
        Rdl(:,:,k+1)=(Tu(1:2,1:2,k)*Rdh(:,:,k)+Tu(1:2,3:4,k))/ ...
            (Tu(3:4,1:2,k)*Rdh(:,:,k)+Tu(3:4,3:4,k));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matrices for propagation
% NOTE: {U|D}(:,:,k) correspond to crossing boundary z(k+1)!
Ux=zeros(2,2,M-1);
if need_propagation_up | output_matrices
    for k=1:M-1
        Ux(:,:,k)=Tu(1:2,1:2,k)+Tu(1:2,3:4,k)*Ruh(:,:,k);
        if ~isempty(find(isnan(Ux(:,:,k))))
            error(['k=' num2str(k) ': Ux']);
        end
    end
end
Dx=zeros(2,2,M-1);
if need_propagation_down | output_matrices
    for k=1:M-1
        Dx(:,:,k)=Td(3:4,1:2,k)*Rdl(:,:,k+1)+Td(3:4,3:4,k);
        if ~isempty(find(isnan(Dx(:,:,k))))
            error(['k=' num2str(k) ': B']);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the matrices, if no sources are given
if output_matrices
    % We only calculate propagation, no radiation
    % No sources, return propagation matrices
    ul=Pu; dh=Pd; uh=Ux; dl=Dx;
    return;
    % The outputs will be Pu, Pd, Ux, Dx, and the reflection coefs.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second part: The wave propagation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(uli)
    uli=[0;0];
end
if isempty(dli)
    dli=[0;0];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the sources are given, calculate the radiation
Ms=length(layers); 
% Cycle over sources at the boundaries
% This cycle is usually fast because Ms << M
upb=zeros(2,M); dmb=zeros(2,M);
for ks=1:Ms
    k=layers(ks); % Number of the containing layer
    Dud=F(:,:,k)\DEH(:,ks);
    % Rd and Ru at the source altitude
    rd=Rdl(:,:,k);
    ru=Rul(:,:,k);
    % Solution for u_+ and d_- due to source kb, at the altitude of the
    % source.
    % "+" stands for above the source, "-" for below the source
    tmp=inv(eye(2)-rd*ru)*(Dud(1:2)-rd*Dud(3:4));
    upb(:,k)=tmp;
    dmb(:,k)=ru*tmp-Dud(3:4);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Propagate up: find "us", up-wave due only to sources below (no
% reflected waves coming from sources above), at altitudes z(k)
usl=zeros(2,M); ush=zeros(2,M-1);
if need_propagation_up
    usl(:,1)=upb(:,1)+uli; % Include sources at z(1)==0, + initial wave
    for k=1:M-1
        % Note: usl(:,k), ush(:,k) include also the sources at the
        % boundary z(k).
        % ush(:,k) includes the same sources as usl(:,k), i.e.,
        % does not include sources ABOVE z(k)
        ush(:,k)=Pu(:,:,k)*usl(:,k);
        % Go across the boundary, and add sources at the boundary
        usl(:,k+1)=Ux(:,:,k)*ush(:,k)+upb(:,k+1);
    end
end
% Propagate down: find "ds", down-wave due only to sources above
% (no reflected waves coming from sources below).
dsl=zeros(2,M); dsh=zeros(2,M-1);
if need_propagation_down
    dsl(:,M)=dli; % There are no sources above this point, only the
    for k=M-1:-1:1
        % Add the sources in layer k+1 (including at boundary z(k+1)),
        % and go across the boundary
        dsh(:,k)=Dx(:,:,k)*(dsl(:,k+1)+dmb(:,k+1));
        % Note: dsl(:,k) only includes sources from z>=z(k+1)
        dsl(:,k)=Pd(:,:,k)*dsh(:,k);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Include all the remaining sources by including the reflected waves
ul=zeros(2,M); dh=zeros(2,M-1);
ul(:,M)=usl(:,M);
if nargout>2
    uh=zeros(2,M-1); dl=zeros(2,M);
    dl(:,M)=dsl(:,M);
end
for k=1:M-1
    ul(:,k)=usl(:,k)+Rdl(:,:,k)*dsl(:,k);
    dh(:,k)=dsh(:,k)+Ruh(:,:,k)*ush(:,k);
    if nargout>2
        % Calculate uh and dl
        uh(:,k)=Pu(:,:,k)*ul(:,k);
        dl(:,k)=Pd(:,:,k)*dh(:,k);
    end
end
