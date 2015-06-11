% Draw palmer's L-shell and lines demarcating 15-degrees magnetic latitude
% By Daniel Golden (dgolden1 at stanford dot edu) August 2008
% $Id$

R_MAX = 4;

figure;
hold on;

%%  Draw L-shell lines using Walt's equation of field line
for switchsides = [-1 1]
	for LShell = [2 2.44 3 4]
		LShellLine = [];
		EndTheta = acos(sqrt(1.0/LShell));
		for ii = -EndTheta:(2*pi/5000):EndTheta
			r = LShell*(cos(ii)^2) * switchsides;
			LShellLine = [LShellLine; r*cos(ii) r*sin(ii) ];
		end
		if LShell == 2.44
			color = 'r';
		else
			color = 'k';
		end
		plot(LShellLine(:,1),LShellLine(:,2),color,'LineWidth',4)
	end
end

%% Draw magnetic latitude line
r = [1 R_MAX];
theta = [15 15]*pi/180;

x = r.*cos(theta);
y = r.*sin(theta);

hold on;
plot(x, y, 'k', 'LineWidth', 4);
plot(x, -y, 'k', 'LineWidth', 4);

%% Draw Earth
r = ones(1, 101);
theta = [0:100]/100*2*pi;

x = r.*cos(theta);
y = r.*sin(theta);

plot(x, y, 'k', 'LineWidth', 4, 'color', 'b');

%% Axis
axis equal
