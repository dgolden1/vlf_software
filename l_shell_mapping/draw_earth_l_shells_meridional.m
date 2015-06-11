% function draw_earth_l_shells
% By Morris

close all;
clear

hold on

% %  Draw Earth's circle
% EarthCircle = [];
% for ii = 0:(2*pi/100):(2*pi);
%    EarthCircle = [EarthCircle; 0.95*sin(ii) 0.95*cos(ii)];
% end
% plot(EarthCircle(:,1),EarthCircle(:,2),'LineWidth',3,'Color',[1 1 1])

% %  Draw bullshit that kind of looks like an ionosphere
% for jj = 1.2:0.01:1.4
%    IonosphereCircle = [];
%    for ii = 0:(2*pi/100):(2*pi);
%        IonosphereCircle = [IonosphereCircle; jj*sin(ii) jj*cos(ii)];
%    end
%    plot(IonosphereCircle(:,1),IonosphereCircle(:,2),'LineWidth',4,'Color',[
% 1 1-(1.4-jj)/0.2 1-(1.4-jj)/0.2])
% end

%  Draw L-shell lines using Walt's equation of field line
for switchsides = [-1 1]
	for LShell = [1.5 2:4]
		LShellLine = [];
		EndTheta = acos(sqrt(1.0/LShell));
		for ii = -EndTheta:(2*pi/5000):EndTheta
			r = LShell*(cos(ii)^2) * switchsides;
			LShellLine = [LShellLine; r*cos(ii) r*sin(ii) ];
		end
		plot(LShellLine(:,1),LShellLine(:,2),'LineWidth',2,'Color',[0 0 0])
	end
end

% Plot the Earth
theta = linspace(0, 2*pi);
plot(cos(theta), sin(theta), 'linewidth', 2, 'color', 'k');

axis equal;
ax = axis;
axis(ax*1.1);
set(gca, 'visible', 'off');
set(gcf, 'color', 'w');
