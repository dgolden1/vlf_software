% trace figure

close all;
clear;

img = imread('bhchorus.png');
imshow(img);
hold on;

MARGIN = 5;

xmin = 24;
xmax = 507;
ymin = 448;
ymax = 643;

p_min = 0;
p_max = 4;
fn_min = 0;
fn_max = 1;

x = [];
y = [];

cx = 0;
cy = 0;
while true
	[cx, cy] = ginput(1);
	if cx < (xmin - MARGIN) || cx > (xmax + MARGIN) || cy < (ymin - MARGIN) || cy > (ymax + MARGIN)
		disp('Done');
		return;
	end
	
	if cx < xmin, cx = xmin; end
	if cx > xmax, cx = xmax; end
	if cy < ymin, cy = ymin; end
	if cy > ymax, cy = ymax; end
	
	disp(sprintf('f/fH = %0.2f', (cx - xmin)/(xmax - xmin)*(fn_max - fn_min) + fn_min));
	disp(sprintf('p = %0.2f', (ymax - cy)/(ymax - ymin)*(p_max - p_min) + p_min));
	
	x = [x cx];
	y = [y cy];
	
	plot(cx, cy, 'ro');
end

ffH = (x - xmin)/(xmax - xmin)*(fn_max - fn_min) + fn_min;
p = (ymax - y)/(ymax - ymin)*(p_max - p_min) + p_min;

figure;
plot(ffH, p, 'LineWidth', 2);
xlabel('f/f_H');
ylabel('Percent');
