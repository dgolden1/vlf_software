function plot_lshell3(L,style)
% Plot the given Lshell with the given style, with axes in meters
physconst

% Starting point, x=2*R_E, y=0, z=0
x = [R_E;0;0];

Bo = .312/10000; 			% B field at Equator (gauss -> tesla)

% Create our ending event function
eventf = @(t,x) testscript_plot_b_endevent(t,x);
opt=odeset('AbsTol',1e-8, 'RelTol', 1e-6, 'Event', eventf);

% Note: normalizing the B field for tracing purposes
% Trace the field line up.
f = @(t,x) bmodel_cartesian( x )*norm(L^2*x)/Bo;
[t,tmp1] = ode45(f, [0 10], L*x,opt);
% Trace the field line down.
f = @(t,x) -bmodel_cartesian( x )*norm(L^2*x)/Bo;
[t,tmp2] = ode45(f, [0 10], L*x,opt);
trace = [flipud(tmp1);tmp2];

if( nargin > 1 )
  plot3(trace(:,1),trace(:,2),trace(:,3),style);
else
  plot3(trace(:,1),trace(:,2),trace(:,3));
end;
  
hold on

