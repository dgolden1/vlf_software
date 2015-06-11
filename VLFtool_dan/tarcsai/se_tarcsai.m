function out = se_tarcsai(t_vec,f_vec,xfit,model,Dci)
% SE_TARCSAI  Convert Tarcsai fitting results to L and neq and their standard errors
%   Usage: se_tarcsai(t_vec,f_vec,xfit,Dci,model)
%   Input:  t_vec: (vector) t along whistler trace (in sec)
%           f_vec: (vector) f along whistler trace (in kHz)
%           xfit: a vector containing the solutions of [D0, fHeq, T]
%           model: (text string) density model to be used in the functions "calcK"
%               and "calckeq" (see calcK.m for details)
%           Dci: dispersion contributed from ionosferic propagation
%               (see Park [1972])

% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

N = length(t_vec);
D0 = xfit(1);
fHeq = xfit(2);
T = xfit(3);
f_vec = 1e3.*f_vec;     % change the unit of the input frequency from kHz to Hz

L = (8.736e5/fHeq)^(1/3);
K = calcK(L,model);
A = K*(3-K)/(K+1);

diff1 = (fHeq - A.*f_vec) ./ (fHeq - f_vec) ./ sqrt(f_vec);
diff2 = -D0 .* sqrt(f_vec) .* (1-A) ./ (fHeq - f_vec).^2;
diff3 = -1 * ones(N,1);

t_vec_fit = D0 ./ sqrt(f_vec) .* (fHeq - A.*f_vec) ./ (fHeq - f_vec) + ...
   Dci ./ sqrt(f_vec) - T;
var_t = norm(t_vec_fit - t_vec)^2 / (N-3); % This is sigma from Tarcsai (1975)

% diff_mat = [diff1 diff2 diff3] ./ sqrt(var_t);
% alpha = diff_mat' * diff_mat;
% C = inv(alpha);

% I like this notation better, because it more closely matches Tarcsai (1975)
diff_mat = [diff1 diff2 diff3]; % This is the A matrix from Tarcsai (1975)
alpha = diff_mat.' * diff_mat;
D = var_t*inv(alpha);

sigma = sqrt(diag(D)');

% More calculation for useful output
sigma_D0 = sigma(1);
sigma_fHeq = sigma(2);
sigma_T = sigma(3);
rDf_sigmad_sigmaf = D(1,2);

Keq = calcKeq(L,model);
neq = Keq * (2*K/(K+1))^2 * D0^2 / L^5;

sigma_L = (L/3)*sigma_fHeq/fHeq;
sigma_neq = neq*sqrt(4*sigma_D0^2/D0^2 + 25/9*sigma_fHeq^2/fHeq^2 + ...
   20/3*rDf_sigmad_sigmaf/D0/fHeq);

disp(['L = ',num2str(L),' +/- ',num2str(sigma_L)])
disp(['neq = ',num2str(neq),' +/- ',num2str(sigma_neq),' cm^-3'])


% 7/14/06 3:59 P.M.
% added code to return the data
out.DensityModel = model;
out.Dci = Dci;
out.D0 = D0;
out.fHeq = fHeq;
out.T = T;
out.L = L;
out.neq = neq;
out.A = A;

out.sigma_D0 = sigma_D0;
out.sigma_fHeq = sigma_fHeq;
out.sigma_T = sigma_T;
out.sigma_L = sigma_L;
out.sigma_neq = sigma_neq;

out.t_vec_fit = t_vec_fit;
out.var_t = var_t;
