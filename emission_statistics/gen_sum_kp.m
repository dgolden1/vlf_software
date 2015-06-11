function [kp_date, sum_kp] = gen_sum_kp
% Generates sum_kp vector
[kp_date, kp] = kp_read_datenum('/home/dgolden/vlf/case_studies/chorus_2003/kp/kp_2003.txt');
sum_kp = kp(1:end-7) + kp(2:end-6) + kp(3:end-5) + kp(4:end-4) + ...
	kp(5:end-3) + kp(6:end-2) + kp(7:end-1) + kp(8:end);
% sum_kp = [zeros(3,1); sum_kp; zeros(4,1)];
sum_kp = [zeros(7,1); sum_kp;]; % sum_kp is sum of previous eight values of kp
