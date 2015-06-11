function x=expintinv(y)
% EXPINTINV Inverse of expint
i1=find(y>0.1);
i2=find(y<=0.1 & y>0);
ii=find(y<=0 | ~isreal(y));
x=zeros(size(y));
x(ii)=NaN;
emin=1e-8;

% y>0.1 -- small x
if ~isempty(i1)
    geuler=0.57721566490153286;
    ey1=exp(-y(i1)-geuler);
    t=ey1;
    err=1; c=0;
    while err>emin
        fp=ey1.*exp(-t)./t;
        tnew=t+(ey1-exp(-expint(t)-geuler))./fp;
        err=max(abs(tnew-t));
        t=tnew;
        c=c+1;
        if c>100
            error('Too many iterations');
        end
    end
    x(i1)=t;
end

% y<=0.1 -- large x
if ~isempty(i2)
    ly2=log(y(i2));
    t=ones(1,length(i2));
    err=1; c=0;
    while err>emin
        fp=-exp(-t)./t./expint(t);
        tnew=t+(ly2-log(expint(t)))./fp;
        err=max(abs(tnew-t));
        t=tnew;
        c=c+1;
        if c>100
            error('Too many iterations');
        end
    end
    x(i2)=t;
end
