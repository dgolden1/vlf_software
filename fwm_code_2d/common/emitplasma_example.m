% Calculate emissions from a ground-based antenna

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify parameters
datadir='antennaemission/'
% Insert one more point at low altitude so that J is interpolated correctly
h=[0 1 80:2:100 105:5:150 160:10:300 320:20:700].';
w=2*pi*3000; % High frequency will require higher horizontal sampling
Nx=2^7;
Ny=2^7;
dx=10e3;
dy=10e3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize various variables
emitplasma_init

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sources -- they will be interpolated
Jz0=zeros(3,3,2);
Jz0(2,2,1)=1;
z0=z(1:2);
x0=[-dx 0 dx];
y0=[-dy 0 dy];
Jx0=[];
Jy0=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculations start here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Pre-calculate nz and modes');
[nz,Fext]=emitplasma_modes(perm,nx,ny,isvacuum);
for tosave={'nz','Fext'}
    eval(['save ' datadir tosave{:} ' ' tosave{:}]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Pre-calculate reflection coefs');
% These are Rd,Ru,U,D in the paper (NOTE THE ORDER!)
[R1,R2,A,B]=emitplasma_reflect(zdim,nz,Fext);
for tosave={'R1','R2','A','B'}
    eval(['save ' datadir tosave{:} ' ' tosave{:}]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note that results up to this point can be re-used for arbitrary current
% configurations.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sources (Delta E, Delta H) in configuration space
disp('Calculate sources');
[J,Jf,DEHf,sindex]=emitplasma_sources(Jx0,Jy0,Jz0,x0,y0,z0,x,y,z,nx,ny);
eval(['save ' datadir 'sources DEHf Jx0 Jy0 x0 y0 z0 J Jf sindex']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Find the total up and down waves and fields');
[Dud,ud,EHf]=emitplasma_ud(DEHf,sindex,Fext,R1,R2,A,B);
for tosave={'Dud','ud','EHf'}
    eval(['save ' datadir tosave{:} ' ' tosave{:}]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Free up some memory
%clear DEHf Jx0 Jy0 Jz0 J Jf
% Not necessary - the arrays in this example are small enough

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take the IFFT
EH=zeros(Nx,Ny,M,6); % WARNING: switched dimensions compared to 2D case!
tstart=now*24*3600;
EH(indx,:,:,:)=ifft(EHf(indx,:,:,:),[],1); % Temporary
EH(:,indy,:,:)=ifft(EH(:,indy,:,:),[],2);
eval(['save ' datadir 'EH EH']);
time6=now*24*3600-tstart;
disp(['Time to solve = ' hms(time6)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% At this point, we can plot horizontal slices of fields at all altitudes
% included in array "h". As an additional calculation, we interpolate the
% field for all altitudes (even those not included in array "h"). This is
% done only at a few values of x and y, to avoid memory problems.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate (u_{k+1}',d_{k+1}') -- the wave variables just below boundary
% k+1 (still in layer k), needed later for slice calculations
disp('Calculate udprime');
udprime=emitplasma_udprime(Fext,ud,Dud,sindex);
eval(['save ' datadir 'udprime udprime']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% y=const and x=const planes, with intermediate points in z direction every
% 0.5 km
disp('Calculate slices');
hi=[0:0.5:700].';
zdimi=1e3*hi.'*k0;
% The boundaries enclosing the emitting region
xsize=50e3; ysize=50e3;
ix1=max(find(x<=-xsize));
ix2=min(find(x>=xsize));
xindex=[ix1 Nx/2 ix2]; % x(xindex) are coordinates of x=const slices
iy1=max(find(y<=-ysize));
iy2=min(find(y>=ysize));
yindex=[iy1 Ny/2 iy2]; % y(yindex) are coordinates of y=const slices
[EHx,EHy]=emitplasma_slices(zdim,nz,Fext,ud,udprime,zdimi,xindex,yindex);
eval(['save ' datadir 'EHslice hi zdimi EHx EHy xindex yindex']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now, use script EMITPLASMA_EXAMPLE_PLOT to plot results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

