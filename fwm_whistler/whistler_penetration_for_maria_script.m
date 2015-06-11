% whistler_penetration_for_maria

% P2: geographic: -85.67, 313.32
%    geomagnetic: -70.07, 19.47
%      dip angle: 180-19.74 deg (from horiz.)

% P3: geographic: -82.75, 28.59
%    geomagnetic: -72.03, 40.49
%      dip angle: 180-20.71 deg (from horiz.)

% Distance from P2 to P3: 827 km at 109 deg

% Is it OK to approximate the ice as an infinite sheet?
% ~2 km of ice
% 750 Hz wave
% Alpha (Inan and Inan p 41-49) = 2*pi*f*sqrt(e_p_r)/(sqrt(2)*3e8)*sqrt(sqrt(1 + (e_pp_r/e_p_r)^2) - 1)
%  = 2.386e-5
% delta = 1/alpha
%  = 41.9e3 = 42 km
% 
% 200 km = 4.8*42 km
% 
% So ice thickness is 4.8x the skin depth => infinite approximation is OK!

output_filename = 'whistler_penetration_for_maria_big.mat';

L = 8.74;
thB = 19.74*pi/180; % Radians from vertical
f = 750; % Hz

xlim = 2000*[-1 1];
ylim = xlim;
gnd_type = 'ice';
load ne_p2; ion_prof = [h Ne];

time_start = now;
[xkm, ykm, zkm, E, B] = whistler_penetration_3d(thB, f, xlim, ylim, gnd_type, ion_prof);

save(output_filename, 'f', 'L', 'thB', 'xkm', 'ykm', 'zkm', 'E', 'B');
time_end = now;

[y m d HH MM SS] = datevec(time_end - time_start);
disp(sprintf('Run started at %s took %d hours, %d minutes, %d seconds', ...
	datestr(time_start), HH, MM, SS));
