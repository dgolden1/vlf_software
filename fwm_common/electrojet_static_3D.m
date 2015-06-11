function [x,y,z,Jx,Jy,Jz,Ex,Ey,Ez,phi]=electrojet_static_3D(varargin)
% Good input values:
% xe=1e3*[-100:10:-70 -60:5:-35 -30:3:30 35:5:60 70:10:100]';
% ye=1e3*[-100:10:-70 -60:5:-35 -30:3:30 35:5:60 70:10:100]';
% ze=1e3*[30 50:10:70 72:2:100 105:5:140 150:10:200 225:25:300].';
% E0=25;
%[sige,sigi,sigtn]=conducair(ze/1e3,'calculate_Nspec',1,'AtmProfile','HAARPsummernight');

keys={'E0','ax','ay','bcz'};
[xe,ye,ze,sig0,dsig,options]=parsearguments(varargin,4,keys);
disturbed=~isempty(dsig);
E0=getvaluefromdict(options,'E0',1);
ax=getvaluefromdict(options,'ax',10*1e3);
ay=getvaluefromdict(options,'ay',10*1e3);
bcz=getvaluefromdict(options,'bcz','Jz=0'); % More stable boundary condition in z

disturbed

nx=length(xe)-2;
ny=length(ye)-2;
nz=length(ze)-2;
dx1=diff(xe);
dy1=diff(ye);
dz1=diff(ze);
x=xe(2:nx+1); y=ye(2:ny+1); z=ze(2:nz+1);

%disp(['nx*ny*nz=' num2str(nx*ny*nz)]);

% Grids of dx,dy,dz
[dx,dy,dz]=ndgrid(dx1,dy1,dz1);
% Differences between shifted points
dxt1=(dx1(1:nx)+dx1(2:nx+1))/2;
dyt1=(dy1(1:ny)+dy1(2:ny+1))/2;
dzt1=(dz1(1:nz)+dz1(2:nz+1))/2;
[dxt,dyt,dzt]=ndgrid(dxt1,dyt1,dzt1);
% Upshifted/downshifted
[dxd,dyd,dzd]=ndgrid(dx1(1:nx),dy1(1:ny),dz1(1:nz));
[dxu,dyu,dzu]=ndgrid(dx1(2:nx+1),dy1(2:ny+1),dz1(2:nz+1));

% The 3D conductivity components
se=zeros(nx+2,ny+2,nz+2,3);
[x3e,y3e,z3e]=ndgrid(xe,ye,ze);
for comp=1:3
    [dummy1,dummy2,sig0tmp]=ndgrid(1:nx+2,1:ny+2,sig0(:,comp));
    se(:,:,:,comp)=sig0tmp;
    if disturbed
        [dummy1,dummy2,dsigtmp]=ndgrid(1:nx+2,1:ny+2,dsig(:,comp));
        se(:,:,:,comp)=se(:,:,:,comp)+dsigtmp.*exp(-x3e.^2./(2*ax^2)-y3e.^2./(2*ay^2));
    end
end

% Make sure the y-boundary periodicity is observed
se(:,1,:,:)=se(:,ny+1,:,:);
se(:,ny+2,:,:)=se(:,2,:,:);

phixe=E0*xe; % The potential along x

if disturbed
    % The div*cond*grad operator for vertical field, given se
    % Gradient of conductivity:
    sx=zeros(nx,ny,nz,3);
    sy=zeros(nx,ny,nz,3);
    sz=zeros(nx,ny,nz,3);
    for comp=1:3
        sx(:,:,:,comp)=(se(3:nx+2,2:ny+1,2:nz+1,comp)-se(1:nx,2:ny+1,2:nz+1,comp))./(2*dxt);
        sy(:,:,:,comp)=(se(2:nx+1,3:ny+2,2:nz+1,comp)-se(2:nx+1,1:ny,2:nz+1,comp))./(2*dyt);
        sz(:,:,:,comp)=(se(2:nx+1,2:ny+1,3:nz+2,comp)-se(2:nx+1,2:ny+1,1:nz,comp))./(2*dzt);
    end
    % div*sig*grad matrix
    spx=+sx(:,:,:,1)+sy(:,:,:,2);
    spy=-sx(:,:,:,2)+sy(:,:,:,1);
    spz=+sz(:,:,:,3);
    sp0=se(2:nx+1,2:ny+1,2:nz+1,1);
    sz0=se(2:nx+1,2:ny+1,2:nz+1,3);
    DSG=zeros(nx,ny,nz,3,3,3);
    DSG(:,:,:,2,2,2)=-2*sp0./(dxd.*dxu)-2*sp0./(dyd.*dyu)-2*sz0./(dzd.*dzu);
    DSG(:,:,:,1,2,2)=-spx./(2*dxt)+sp0./(dxd.*dxt);
    DSG(:,:,:,3,2,2)=+spx./(2*dxt)+sp0./(dxu.*dxt);
    DSG(:,:,:,2,1,2)=-spy./(2*dyt)+sp0./(dyd.*dyt);
    DSG(:,:,:,2,3,2)=+spy./(2*dyt)+sp0./(dyu.*dyt);
    DSG(:,:,:,2,2,1)=-spz./(2*dzt)+sz0./(dzd.*dzt);
    DSG(:,:,:,2,2,3)=+spz./(2*dzt)+sz0./(dzu.*dzt);
    % Boundary conditions: cyclic in y, and fixed phi on x,z boundaries
    % Background electric field is along x
    rhs=zeros(nx,ny,nz);
    % x boundary -- phi(ix==0)=phi1, phi(ix==nx+1)==phi2
    rhs(1,:,:)=-phixe(1)*DSG(1,:,:,1,2,2);
    rhs(nx,:,:)=-phixe(nx+2)*DSG(nx,:,:,3,2,2);
    % y boundary -- periodic -- automatic
    % Different z boundary conditions (Ez==0 works a little better)
    switch bcz
        case 'phi=phi0'
            % z boundary -- phi=phix
            rhs(:,:,1)=-ndgrid(phixe(2:nx+1),1:ny).*DSG(:,:,1,2,2,1);
            rhs(:,:,nz)=-ndgrid(phixe(2:nx+1),1:ny).*DSG(:,:,nz,2,2,3);
        case 'Jz=0'
            % z boundary -- Ez==0
            DSG(:,:,1,2,2,2)=DSG(:,:,1,2,2,2)+DSG(:,:,1,2,2,1);
            DSG(:,:,nz,2,2,2)=DSG(:,:,nz,2,2,2)+DSG(:,:,nz,2,2,3);
        otherwise
            error(['unknown boundary condition: ' bcz]);
    end
    disp(['Solving linear system for ' num2str(nx*ny*nz) ' variables, please wait ...']);
    phi=solve3d(DSG,rhs,0,1,0,'cross',1);
else
    phi=ndgrid(phixe(2:nx+1),1:ny,1:nz);
end
phie=zeros(nx+2,ny+2,nz+2);
phie(2:nx+1,2:ny+1,2:nz+1)=phi;
phie(1,:,:)=phixe(1);
phie(nx+2,:,:)=phixe(nx+2);
phie(:,1,:)=phie(:,ny+1,:);
phie(:,ny+2,:)=phie(:,2,:);
phie(:,:,1)=phie(:,:,2); phie(:,:,nz+2)=phie(:,:,nz+1);

% The fields and currents
% E
Ex=(phie(3:nx+2,2:ny+1,2:nz+1)-phie(1:nx,2:ny+1,2:nz+1))./(2*dxt);
Ey=(phie(2:nx+1,3:ny+2,2:nz+1)-phie(2:nx+1,1:ny,2:nz+1))./(2*dyt);
Ez=(phie(2:nx+1,2:ny+1,3:nz+2)-phie(2:nx+1,2:ny+1,1:nz))./(2*dzt);
% The currents
s=se(2:nx+1,2:ny+1,2:nz+1,:);
Jx=s(:,:,:,1).*Ex-s(:,:,:,2).*Ey;
Jy=s(:,:,:,2).*Ex+s(:,:,:,1).*Ey;
Jz=s(:,:,:,3).*Ez;


