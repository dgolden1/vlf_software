function u=ftest(z,params)
u=1;
roots=params{1}; poles=params{2};
for k=1:length(roots)
    u=u.*(z-roots(k));
end
for k=1:length(poles)
	u=u./(z-poles(k));
end
%u=z-(0.5-i*.5);
