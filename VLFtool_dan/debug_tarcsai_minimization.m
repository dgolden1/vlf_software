% function debug_tarcsai_minimization
% Debug function to try to determine the best optimization method for the
% Tarcsai algorithm
% 
% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

close all;
clear;

load /home/dgolden/vlf/Whistler_Analysis/case_studies/palmer_20040723_0355/PALMERBB_20040723_035530_wh_02.mat;
x0 = [60 100000 0].';
Dci = 6;
model = 'DE-1';

t_vec = wh.time - wh.sferic;
f_vec = wh.freq;

% @(x) fun_tarcsai(x,t_vec,f_vec,model,Dci)
