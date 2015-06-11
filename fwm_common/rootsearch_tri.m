function [Csol,Cpole]=rootsearch_tri(varargin)
% Search for the roots of complex function F in an arbitrary region with
% triangles method.
% Usage:
%   Csol=rootsearch(@F,params,boundary,dC,options);
% Cmin -- lower left corner
% Cmax -- upper right corner
% dC=.01*(1+i);

% Parse arguments and default values
keys={'triangles','debug','Newton-Raphson','max_error','shift'};
[F,params,boundary,dC,options]=parsearguments(varargin,3,keys);
debuglevel=getvaluefromdict(options,'debug',0);
doplot=debuglevel>1;
use_nr=getvaluefromdict(options,'Newton-Raphson',0);
mode=getvaluefromdict(options,'triangles','horizontal');
max_error=getvaluefromdict(options,'max_error',1e-6);
if isempty(dC)
    [b1,b2]=ndgrid(boundary,boundary);
    dCr=min(min(abs(real(b1-b2))))/10;
    dCi=min(min(abs(imag(b1-b2))))/10;
    dC=dCr+i*dCi;
end
thick=real(dC)*1e-3; % boundary thickness

% Make the boundary closed
n=length(boundary);
if(boundary(1)~=boundary(n))
    boundary(n+1)=boundary(1);
end

switch mode
    case 'horizontal'
        Cshift=getvaluefromdict(options,'shift',.25*real(dC)+i*.5*imag(dC));
        dCtab=real(dC)*[1 .5 -.5 -1 -.5 .5]+i*imag(dC)*[0 -1 -1 0 1 1];
    case 'vertical'
        Cshift=getvaluefromdict(options,'shift',.5*real(dC)+i*.25*imag(dC));
        dCtab=real(dC)*[0 1 1 0 -1 -1]+i*imag(dC)*[1 .5 -.5 -1 -.5 .5];
    otherwise
        error(['unknown option (triangles) = ' mode]);
end

Cshiftarr=[Cshift -conj(Cshift) -Cshift conj(Cshift)];
for k=1:4
    Corig=boundary(1)-Cshiftarr(k);
    if num_winds(boundary-Corig,thick)==0
        break;
    end
end

% The boundary in the triangular mesh
C=Corig;
Cb=[]; direction=[]; Fb=0;
while 1
    Cb=[Cb C]; Fb=[Fb F(C,params)];
    % The next boundary point
    wasin=0;
    for k=0:6
        d=mod(k,6)+1;
        C1=C+dCtab(d);
        nwinds=num_winds(boundary-C1,thick);
        %disp([num2str(d) ': C=' num2str(C1) '; num_winds=' num2str(nwinds)]);
        if wasin & nwinds==0
            C=C1;
            break
        end
        wasin=(wasin | nwinds~=0);
    end
    direction=[direction d];
    if is_same(C,Corig,dC,mode)
        break;
    end
end
if debuglevel>0
    disp('ROOTSEARCH: found boundary')
end

Fphase=unwrap(angle([Fb Fb(1)]))/(pi/2);
numroots=(Fphase(end)-Fphase(1))/4;
if debuglevel>1
    figure; plot(Fphase);
end
if debuglevel>0
	disp(['NUM ROOTS - NUM POLES = ' num2str(numroots)]);
end

if numroots==0
	% special treatment
	Csol=[]; Cpole=[]; return;
	dphi=max(Fphase)-min(Fphase);
	phi1=min(Fphase)+dphi/3;
	phi2=max(Fphase)-dphi/3;
else
	phi1=0;
	phi2=-1;
end
[Ccreal,Chopreal]=follow_phase(-phi1,F,params,dC,mode,Cb,boundary,thick,direction,dCtab,debuglevel);
[Ccimag,Chopimag]=follow_phase(-phi2,F,params,dC,mode,Cb,boundary,thick,direction,dCtab,debuglevel);

if doplot
    figure;
    plot(Cb,'b-'); hold on;
    plot(Ccreal,'r-'); plot(Ccimag,'g-');
    grid on; %axis equal
end

% Group the triangles of solutions
kr=[];
for k=1:length(Ccreal)
    Cc=Ccreal(k);
    if ~isempty(find(is_same(Cc,Ccimag,dC,mode)))
        kr=[kr k];
    end
end

kr
nn=length(kr);
tmp=diff(kr);
ig=find(0==[0 (tmp==1 | tmp==-1)]); % addresses of starts of the groups
nroots=length(ig);
lg=diff([ig nn+1]); % lengths of the groups
Csol=[]; Cpole=[];
kstart=kr(ig);
for k=1:nroots
    kstart=kr(ig(k));
    g=Ccreal(kstart:kstart+lg(k)-1);
    if debuglevel>1
        disp(['Group ' num2str(k) ':']);
        for kk=1:lg(k)
            disp([' F(' num2str(g(kk)) ')=' num2str(F(g(kk),params))]);
        end
    end
    if lg(k)<=0
        continue;
    end
    % Find the vertices of triangles around the group
    vv=[];
    switch mode
        case 'vertical'
            for kk=1:lg(k)
                tritype=mod(round(real(g(kk)-Corig)/(real(dC)/3)),3);
                if tritype==1
                    tmp=-real(dC)/3+i*imag(dC)/2;
                    vv=[vv g(kk)+real(dC)*2/3 g(kk)+tmp g(kk)+conj(tmp)];
                else
                    tmp=real(dC)/3+i*imag(dC)/2;
                    vv=[vv g(kk)-real(dC)*2/3 g(kk)+tmp g(kk)+conj(tmp)];
                end
            end
        case 'horizontal'
            error('not implemented')
        otherwise
            error(['unknown option (triangles) = ' mode]);
    end
    nv=length(vv);
    for kk=1:nv
        if ~isnan(vv(kk))
            ii=find(is_same(vv,vv(kk),dC,mode) & [1:nv]~=kk);
            vv(ii)=NaN;
        end
    end
    vert=vv(find(~isnan(vv)));
    nvert=length(vert);
    if doplot
        plot(g,'k-','linewidth',2);
    end

        % Find the boundary of the group, using a very similar algorithm
        Cgb=[];
        C0=vert(1);
        C=C0; kvert=1;
        while 1
            Cgb=[Cgb C];
            % The next boundary point
            wasout=0;
            for kk=6:-1:0
                d=mod(kk,6)+1;
                C1=C+dCtab(d);
                tmp=find(is_same(C1,vert,dC,mode) & [1:nvert]~=kvert);
                isout=isempty(tmp);
                if wasout & ~isout
                    kvert=tmp;
                    C=C1;
                    break
                end
                wasout=(wasout | isout);
            end
            if is_same(C,C0,dC,mode)
                break;
            end
        end
        % Close the boundary
        Cgb=[Cgb C0];
        if doplot
            plot(vert,'ko');
            plot(Cgb,'c-');
        end
        % Determine the order of the root
        p=zeros(1,length(Cgb));
        for kk=1:length(Cgb)
            p(kk)=angle(F(Cgb(kk),params))/pi;
        end
        daz=diff(p);
        ind=find(abs(daz)>1);
        order=sum(-sign(daz(ind)))
        if abs(order)==0
            vert
            error('root + pole');
        end

    if ~use_nr
        Csol(k)=sum(g)/lg(k);
        continue;
    end
    % Use Newton-Raphson method (optional)
    % Use the first and last element in the group as the initial guess
    % We use the fact that there are always > 1 member of the group
    % (due to the triangular mesh)
    if order>0
		C1=g(1); f1=F(C1,params);
		C2=g(lg(k)); f2=F(C2,params);
		while 1
			Cchange=-f2*(C2-C1)./(f2-f1);
			C1=C2;
			C2=C2+Cchange;
			f1=f2;
			f2=F(C2,params);
            if doplot
                plot([C1 C2],'kx-');
            end
			if abs(f2)<max_error
				break
			end
			%pause
		end
        if debuglevel>1
            disp([' Root: F(' num2str(C2) ')=' num2str(F(C2,params))]);
        end
        Csol=[Csol C2];
	else
		% we have a pole of order (-order)
        C1=g(1); f1=1./F(C1,params);
        C2=g(lg(k)); f2=1./F(C2,params);
        while 1
            Cchange=-f2*(C2-C1)./(f2-f1);
            C1=C2;
            C2=C2+Cchange;
            f1=f2;
            f2=1./F(C2,params);
            if doplot
                plot([C1 C2],'kx-');
            end
            if abs(f2)<max_error | isnan(f2)
                break
            end
        end
        if debuglevel>1
            disp([' Pole: 1/F(' num2str(C2) ')=' num2str(1/F(C2,params))]);
        end
        Cpole=[Cpole C2];
    end
end
if debuglevel>0
    disp(['ROOTSEARCH: found roots with method = ' num2str(use_nr)]);
end

% Sort by real part
[dummy,ii]=sort(real(Csol));
Csol=Csol(ii);
if doplot
    for k=1:length(Csol)
        plot(Csol(k),'ko');
    end
    for k=1:length(Cpole)
        plot(Cpole(k),'kx');
    end    
end

% END

% Auxiliary functions
function topol=num_winds(z,d)
% Number of CCW winds
% Adopted from my earlier IDL function with the same name
% Count discontinuities of azimuthal angles.
% If there is an odd number of discontinuities, we are inside.
% Close to boundary is considered outside
topols=zeros(1,4);
for k=1:4
    daz=diff(angle(z+d*i^k))/pi;
    ind=find(abs(daz)>1); 
    topols(k)=sum(-sign(daz(ind)));
end
topol=min(topols);
%res=mod(topol,2);

function area=get_area(z)
z=z(:).';
n=length(z);
area=0.5*sum(imag(conj(z).*[z(2:n) z(1)]));

function res=is_same(C1,C2,dC,mode)
e=.5;
switch mode
    case 'horizontal'
        res=(abs(real(C1-C2))<e*real(dC)/2 & abs(imag(C1-C2))<e*imag(dC));
    case 'vertical'
        res=(abs(imag(C1-C2))<e*imag(dC)/2 & abs(real(C1-C2))<e*real(dC));
end

function [Cc,Choparr]=follow_phase(ipower,F,params,dC,mode,Cb,boundary,thick,direction,dCtab,debuglevel)
Cc=[]; Choparr=[];
kx=[];
skip=1;
nb=length(Cb);
for k=1:nb
	if any(k==kx)
		skip=1;
		continue;
	end
	if skip
		skip=0;
		C1=Cb(k); f1=F(C1,params);
	else
		C1=C2; f1=f2;
	end
	C2=Cb(mod(k,nb)+1);
	f2=F(C2,params);
	t=real(i^ipower*[f1 f2]);
	if t(1)*t(2)<0
		Choparr=[Choparr C1 C2];
		Cc=[Cc NaN NaN];
		din=mod(direction(k)-2,6)+1; % direction into the region
		Chop=Cb(k)+dCtab(din);
		while 1
			isin=(num_winds(boundary-Chop,thick)~=0);
			ibhop=find(is_same(Chop,Cb,dC,mode));
			if ~isin & isempty(ibhop)
				kx=[kx min(ib1,ib2)];
				Cc=[Cc NaN];
				Choparr=[Choparr NaN];
				break;
			end
			Choparr=[Choparr Chop];
			Cc=[Cc (C1+C2+Chop)/3];
			fhop=F(Chop,params);
			t=real(i^ipower*[f1 f2 fhop]);
			if t(1)*t(3)<0
				tmp=Chop+C1-C2;
				C2=Chop; f2=fhop; ib2=ibhop;
				Chop=tmp; fhop=F(Chop,params);
			elseif t(2)*t(3)<0
				tmp=Chop+C2-C1;
				C1=Chop; f1=fhop; ib1=ibhop;
				Chop=tmp; fhop=F(Chop,params);
			else
				error('unknown');
			end
		end
	end
end
if debuglevel>0
	ncells=get_area(boundary)/(real(dC)*imag(dC));
	disp(['ROOTSEARCH: found phi=' num2str(ipower) ...
		'*pi/2 curves, length=' num2str(length(Cc)) ...
		'; time saving factor=' num2str(length(Cc)/ncells)]);
end
