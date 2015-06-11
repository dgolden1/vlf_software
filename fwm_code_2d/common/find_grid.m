function [xb,fc]=find_grid(f,x1,x2,dxi,e)
% Find the grid that gives a fixed error in the integration
% Error is estimated as |f''|*dx^3/24,
% xb are the boundary values
% xc are the center values
% dx is diff(xb)
% Error at xc(i) is abs(fb(i+1)+fb(i)-fc(i))*dx(i)/6

% Initial grid, with dxi as the maximum allowed dx:
N=ceil((x2-x1)/dxi);
dxi=(x2-x1)/N;
% Initial values for xb,xc,fb,fc:
xb=x1+dxi*[0:N]; % Size N+1
xc=(xb(1:N)+xb(2:N+1))/2;
dx=diff(xb); % Size N
fb=f(xb);
fc=f(xc);
while 1
	ei=abs(fb(1:N)+fb(2:N+1)-fc).*dx/6; % size N
	c=(ei>e);
	il=find(~c);
	ii=find(c);
	if isempty(ii)
		break
	end
	% Insert xc(ii) as new xb(ii)
	fbadd=fc(ii);
	xbadd=xc(ii);
	xbnew=[xb xbadd];
	fbnew=[fb fbadd];
	% Calculate new values
	xcadd=[xc(ii)-dx(ii)/4 xc(ii)+dx(ii)/4];
	fcadd=f(xcadd);
	% Drop the old values of xc
	xcnew=[xc(il) xcadd];
	fcnew=[fc(il) fcadd];
	% Update the arrays to new values
	[xb,ibs]=sort(xbnew);
	fb=fbnew(ibs);
	[xc,ics]=sort(xcnew);
	fc=fcnew(ics);
	dx=diff(xb);
	N=length(xc);
end
