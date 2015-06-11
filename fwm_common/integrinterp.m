function yi=integrinterp(x,y,xie)
% Interpolation
n=length(xie)-1;
yie=interp1(x,y,xie);
dxe=diff(xie);
for k=1:n
    ii=find(x>xie(k) & x<xie(k+1));
    % Integrate
    x1=[xie(k) x(ii) xie(k+1)];
    y1=[yie(k) y(ii) yie(k+1)];
    dx=diff(x1);
    yi(k)=0.5*sum(([yie(k) y(ii)]+[y(ii) yie(k+1)]).*dx)./dxe(k);
end
