function out = fun_daniell(x,t_vec,f_vec,model,Dci)
% FUN_DANIELL  Function to be minimized in Daniell's formula
%    Usage: to be used by the function "fminsearch" (Matlab version 6)
%           or "fmins" (version 5 or older), for example,
%           x_fit = fminsearch('fun_daniell',x0,[],t_vec,f_vec,model,Dci)
%    Input: x: [D0 fHeq T], where
%               D0 is the zero disperson
%               fHeq is the equatorial electron gyrofrequency (in Hz, not kHz)
%               T is the sferic time (in sec)
%           t_vec: (vector) t along whistler trace (in sec)
%           f_vec: (vector) f along whistler trace (in kHz)
%           model: (text string) density model to be used in the function "calcK"
%               (see calcK.m for details)
%           Dci: dispersion contributed from ionosferic propagation
%               (see Park [1972])

M = length(x);
if (length(t_vec) ~= length(f_vec))
   error('Input vectors t and f do not have same length.');
end

D0 = x(1);
fHeq = x(2);
T = x(3);
f_vec = 1e3.*f_vec;     % change the unit of the input frequency from kHz to Hz

% Calculate AD and G2
L = (8.736e5/fHeq)^(1/3);
K = calcK(L,model);
ADup = K*(3-K)/(K+1) + (K-1)^2/2/(K+1) * (2/(K-1) + log(1-1/K));
ADdown = 1 + (K-1)^2/2/(K+1) * (2/(K-1) + log(1-1/K));
AD = ADup/ADdown;
G2 = -0.5*D0*(1-AD);

t_vec_fit = D0./sqrt(f_vec) .* (fHeq - AD.*f_vec)./(fHeq - f_vec) + ...
   G2./sqrt(f_vec).*log(1-f_vec./fHeq) + Dci./sqrt(f_vec) - T;
out = sum((t_vec - t_vec_fit).^2);
