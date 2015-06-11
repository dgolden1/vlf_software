% Script to extract palmer cal 2001 info

img = imread('palmer_cal_img.png');
figure;
imshow(img); axis tight;
hold on;

x_min = 70;
y_max = 649;
x_max = 837;
y_min = 89;

% All logarithmic values
f_min = 1; % E.g., the true f_min is 10^1
f_max = 5;
atten_min = -1;
atten_max = 0;

MARGIN = 5;

f_vec = [];
atten_vec = [];
while true
	[cx, cy] = ginput(1);
	if isempty(cx) || (cx < (x_min - MARGIN) || cx > (x_max + MARGIN) || cy < (y_min - MARGIN) || cy > (y_max + MARGIN))
		disp('Done');
		break;
	end
	
	if cx < x_min, cx = x_min; end
	if cx > x_max, cx = x_max; end
	if cy < y_min, cy = y_min; end
	if cy > y_max, cy = y_max; end
	

	f_log = (cx - x_min)/(x_max - x_min)*(f_max - f_min) + f_min;
	atten_log = (y_max - cy)/(y_max - y_min)*(atten_max - atten_min) + atten_min;
	
	disp(sprintf('f = %0.2f', 10^f_log));
	disp(sprintf('atten = %0.2f', 10^atten_log));
	
	f_vec = [f_vec 10^f_log];
	atten_vec = [atten_vec 10^atten_log];
	
	plot(cx, cy, 'ro');
end

figure;
loglog(f_vec, atten_vec, '-o', 'LineWidth', 2);
grid on;
xlabel('f (Hz)');
ylabel('atten');
increase_font(gcf, 16);
xlim([1e1 1e5]);
ylim([1e-1 1e0]);
