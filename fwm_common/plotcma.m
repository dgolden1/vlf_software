function plotcma(mM,scale,xlim,ylim,draw_legend)
% PLOTCMA Plot the Clemmow-Mullaly-Allis diagram for cold 2-comp plasma
% Usage:
%  plotcma(mM,scale,xlim,ylim)
% Inputs:
%    mM -- mass ratio me/mi (default=0.1);
%    scale -- 'linear' (default) or 'log'
%    xlim,ylim -- the limits for the parameters X=Xe=wpe^2/w^2 and Y=Ye=wHe/w
% Outputs: none (except the plots)
% Plot #1 (upper left)  -- (X,Y) parameter plane with bounding lines
%    Click anywhere inside this subplot to see the information about the
%    refraction coefficient on other subplots.
% Plot #2 (lower left)  -- n(theta), the refraction coefficent
%    n is plotted for both modes for different angles.
%    B0 is vertical upward.
%    The red lines show the resonant angle (n=inf).
%    The cyan lines show the angle where the E polarization is changed.
%    The thick lines show CCW (right) polarization, thin lines are for CW.
%    Dashed lines are evanescent waves (n=in'), the imaginary part of n is
%    plotted.
% Plot #3 (lower right) -- phase velocity (divided by c)
%    1/n as a function of theta. The line styles mean the same as in the
%    plot for n.
% Plot #4 (upper right) -- E polarization
%    The plot location is chosen so that n and vph plots are close to each
%    other.
%    E=(Ex,i*Eyi,Ez) for exp(-i*w*t) time dependence, Ex,Eyi,Ez are real.
%    The polarization for each wave is vizualized as an ellipse and
%    a vector, with origin at the point in (nx,ny) plane.
%    The ellipses have horizontal semi-axis ~Ex, vertical ~Eyi.
%    The vectors have horizontal component ~Ex (same as for ellipse),
%    vertical ~Ez.
%    If the vector horizontal component is > 0, the wave is CCW (if <0, CW)
if nargin<1 | isempty(mM)
    mM=0.1;
end
if nargin<2 | isempty(scale)
    if mM>0.05
        scale='linear';
    else
        scale='log';
    end
end
if nargin==3
    error('Please specify both xlim and ylim');
end
if nargin<4 | isempty(xlim)
    if strcmp(scale,'linear')
        xlim=[0 (1+mM)/4/mM+1];
        ylim=[0 (1/mM)+1];
    else % 'log'
        xlim=[0.1 10/mM];
        ylim=[0.1 10/mM];
    end
end
if nargin<5 | isempty(draw_legend)
    draw_legend=0;
end
subplot(2,2,1);
if strcmp(scale,'linear')
    x=[xlim(1):.001:xlim(2)]';
    y=[ylim(1):.001:ylim(2)]';
else % 'log'
    x=10.^[log10(xlim(1)):0.001:log10(xlim(2))]';
    y=10.^[log10(ylim(1)):0.001:log10(ylim(2))]';
end
%x=10.^[-1:.001:2]';
%y=10.^[-1:.001:2]';
%x=10.^[-.3:.001:.3]';
%y=10.^[0.7:.001:1.3]';
xmin=min(x); xmax=max(x);
ymin=min(y); ymax=max(y);
% S=(R+L)/2=0
xS=(1-y.^2).*(1-mM^2*y.^2)./(1-mM*y.^2)/(1+mM);
xS(find(real(xS)==0 | xS<xmin | xS>xmax))=nan;
% R=0 (R is the CCW dielectric constant)
xR=(1-y).*(1+mM*y)/(1+mM);
xR(find(xR<xmin | xR>xmax))=nan;
% L=0 (L is the CW dielectric constant)
xL=(1+y).*(1-mM*y)/(1+mM);
xL(find(xL<xmin | xL>xmax))=nan;
% RL=PS (P=1-Xe-Xi is the Ez dielectric constant)
%xN=(-y.^2*mM^2+(1+mM^2-mM))/mM/(1+mM);
yN=sqrt(1+1/mM^2-(1+x*(1+mM))/mM);
yN(find(x<xmin | x>1/(1+mM) | real(yN)==0))=nan;
plot([xR xL xS],y); grid on;
set(gca,'xscale',scale,'yscale',scale);
hold on
plot(x,yN,'c');
xlines=[[xmin xmax] nan [xmin xmax] nan [1 1]/(1+mM)];
ylines=[[1 1] nan [1 1]/mM nan [ymin ymax]];
plot(xlines,ylines,'k');
plot([xmin xmax],[1 1]/sqrt(mM),'k--');
if draw_legend
    ll=legend('R=0 (cutoff hi)','L=0 (cutoff lo)',...
        'S=0 (hybrid res)','RL=PS',...
        '\omega=\omega_{He,Hi,p}',...
        '\omega=(\omega_{He}\omega_{Hi})^{1/2}');
end
set(gca,'xlim',[xmin xmax],'ylim',[ymin ymax]);
xlabel('X=\omega_{pe}^2/\omega^2');
ylabel('Y=\omega_{He}/\omega');
title(['Two-component cold plasma, q_i=-q_e, m/M=' num2str(mM)]);
plot(1,1,'kx','linewidth',2,'MarkerSize',10,'Visible','off')
hh=get(gca,'children');
for k=1:length(hh)
    XY=hh(k);
    if get(XY,'Marker')=='x'
        break;
    end
end
hold off
while 1
    subplot(2,2,1);
    [X,Y]=ginput(1);
    if X<xmin | Y<ymin | X>xmax | Y>ymax
        break
    end
    set(XY,'XData',X,'YData',Y,'Visible','On');
    [n2,s,c,res,thch,p,Ex,Eyi,Ez]=plotcma_coldplasma(X,Y,mM);
    n=sqrt(n2); n(find(n2<=0))=nan;
    nevan=sqrt(-n2); nevan(find(n2>=0))=nan;
    for iplot=3:4
        subplot(2,2,iplot);
        if iplot==4
            npower=-1;
            plot(s./n,c./n); axis equal; grid on;
            t='v_{ph}';
        else
            npower=1;
            plot(s.*n,c.*n); axis equal; grid on;
            t='n';
            hold on; plot(s.*nevan,c.*nevan,'--'); hold off;
        end
        % Note the polarization
        t3='';
        %p=Ex./Eyi;
        if ~all(isnan(p(1,:)))
            hold on
            for k=1:2
                if p(1,k)>0
                    plot([0 0],n(1,k)^npower*[-1 1],'rx');
                else
                    plot([0 0],n(1,k)^npower*[-1 1],'ro');
            end
            end
            %nRH=(p>0).*n;
            nRH=n;
            nRH(find(~(p>0)))=nan;
            if iplot==3
                plot(s.*nRH,c.*nRH,'linewidth',3);
            else
                plot(s./nRH,c./nRH,'linewidth',3);
            end
            hold off
            t3='; x,o - RH/LH (\theta=0)';
        end
        if ~isnan(res)
            hold on
            x1=get(gca,'xlim');
            y1=get(gca,'ylim');
            x=min(x1(2),y1(2)*tan(res));
            plot(x*[-1 1],x/tan(res)*[-1 1],'r');
            plot(x*[-1 1],x/tan(res)*[1 -1],'r');
            hold off
        end
        if ~isnan(thch)
            hold on
            x1=get(gca,'xlim');
            y1=get(gca,'ylim');
            x=min(x1(2),y1(2)*tan(thch));
            plot(x*[-1 1],x/tan(thch)*[-1 1],'c');
            plot(x*[-1 1],x/tan(thch)*[1 -1],'c');
            hold off
        end
        P=abs(1-X*(1+mM));
        t2='';
        %if P>0
        hold on
        plot(P^(npower/2)*[-1 1],[0 0],'ro');
        hold off
        t2='o - ord. (\theta=\pi/2)';
        %end
        if iplot==3
            title(sprintf('%s: X=%2.2f, Y=%2.2f\n%s%s',t,X,Y,t2,t3));
            %title([t ': X=' num2str(X) ', Y=' num2str(Y) t2 t3]);
        else
            title(t)
        end
    end % iplot
	
	% The polarization
	subplot(2,2,2);
	dth=20;
	ii=[0:dth:360-dth]+1;
	ellx=[]; elly=[]; vecx=[]; vecz=[];
	for k=1:2
		nx=s(ii,k).*n(ii,k); nx=nx(:);
		nz=c(ii,k).*n(ii,k); nz=nz(:);
		Exf=Ex(ii,k); Exf=Exf(:);
		Eyf=Eyi(ii,k); Eyf=Eyf(:);
		Ezf=Ez(ii,k); Ezf=Ezf(:);
		%quiver(nx,nz,Exf,Ezf,1);
		% Scaling: the length which must not be exceeded
		maxlen=min(sqrt(diff(nx).^2+diff(nz).^2));
		if isnan(maxlen)
			maxlen=min(sqrt(nx.^2+nz.^2));;
		end
		% The ellipses
		th=[0:5:360]*pi/180;
		ellipsex=(Exf*[cos(th) nan])'; ellipsex=ellipsex(:);
		ellipsey=(Eyf*[sin(th) nan])'; ellipsey=ellipsey(:);
		% Determine the scale at which the fields have to be drawn
		scale=0.5*maxlen/max([ellipsex;ellipsey]);
		nxm=meshgrid(nx,1:length(th)+1);
		nzm=meshgrid(nz,1:length(th)+1);
		vectorx=[nx nx+Exf*scale repmat(nan,size(nx))]';
		vectorz=[nz nz+Ezf*scale repmat(nan,size(nz))]';
		ellx=[ellx ellipsex*scale+nxm(:)];
		elly=[elly ellipsey*scale+nzm(:)];
		vecx=[vecx vectorx(:)];
		vecz=[vecz vectorz(:)];
	end
	plot(real(ellx),real(elly));
	hold on;
	plot(vecx,vecz);
	hold off;
	axis equal;
	title('Polarization: (x,y)-ellipse, (x,z)-vector');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The internal version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [n2,s,c,thres,thch,p,Ex,Eyi,Ez]=plotcma_coldplasma(X,Y,mM)
% COLDPLASMA Calculate the refraction coef. and fields
% Inputs:
%  X=wpe^2/w^2 where wpe is the electron plasma frequency;
%  Y=wHe/w where wHe is the electron gyrofrequency;
%  mM=m/M is the mass ratio of electron and positive singly charged ion.
% Ouputs:
%  n2 -- the square of the refraction coefficient (2D array, first index is
%        angle index, second is the mode);
%  s,c -- sin and cos of the angle between k and B (2D array of same size);
%  thres -- resonance angle
%  thch -- angle at which the polarization changes
%  p == i*Ex/Ey (polarization)
%  Ex, Eyi, Ez -- electric field normalized to |E|=1 (Eyi=Ey/i). All these
%                 are real.
th=meshgrid([0:360]'*pi/180,1:2)';
e=ones(size(th)); e(:,2)=-1;
s=sin(th);
c=cos(th);
P=1-X;
R=1-X/(1-Y);
L=1-X/(1+Y);
if mM>0
    P=P-mM*X;
    R=R-mM*X/(1+mM*Y);
    L=L-mM*X/(1-mM*Y);
end
S=(R+L)/2;
D=(R-L)/2;
A=S*s.^2+P*c.^2;
B=R*L*s.^2+P*S*(1+c.^2);
F=sqrt((R*L-P*S)^2*s.^4+4*P^2*D^2*c.^2);
n2=(B+e.*F)./(2*A);
% Discard evanescent waves
%n(find(real(n)==0))=nan;
% The resonance angle
t2=-P/S;
if t2>=0
    thres=atan(sqrt(t2));
	thch=nan;
else
    thres=nan;
	if (-t2)<=1
		thch=asin(sqrt(-t2));
	else
		thch=nan;
	end
end
% Polarization, iEx/Ey, =1 (RH) =-1 (LH)
p=(n2-S)./D;
p(find(n2<=0))=nan;
% Electric field components (unnormalized)
Ex1=n2-S;
Ex2=n2.*s.^2-P;
Ex=Ex1.*Ex2;
Eyi=D*Ex2; % =Ey/i
Ez=Ex1.*n2.*c.*s;
% Normalized
Ea=sqrt(Ex.^2+Eyi.^2+Ez.^2);
if any(Ea==0)
	error('Ea=0');
end
Ex=Ex./Ea; Eyi=Eyi./Ea; Ez=Ez./Ea;
% Make sure that Eyi>=0
sig=1-2*(Eyi<0);
Ex=Ex.*sig; Eyi=Eyi.*sig; Ez=Ez.*sig;

