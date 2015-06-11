function out = fun_tarcsai(x,t_vec,f_vec,model,Dci)
% FUN_TARCSAI  Function to be minimized in Tarcsai's (Bernard's) formula
%    Usage: to be used by the function "fminsearch" (Matlab version 6)
%           or "fmins" (version 5 or older), for example,
%           x_fit = fminsearch('fun_tarcsai',x0,[],t_vec,f_vec,model,Dci)
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

% Modified by Daniel Golden (dgolden1 at stanford dot edu) August 2007

% $Id:fun_tarcsai.m 522 2007-09-24 21:29:08Z dgolden $

M = length(x);
if (length(t_vec) ~= length(f_vec))
   error('Input vectors t and f do not have same length.');
end

D0 = x(1); 
fHeq = x(2); 
T = x(3);
f_vec = 1e3.*f_vec;     % change the unit of the input frequency from kHz to Hz

% Calculate A
% This equation is correct as written; the ^(1/3) factor is misplaced in Tarcsai
% 1975 (p4), but is correct in Park 1972 (p10).
% -DG
L = (8.736e5/fHeq)^(1/3);

% 7/28/06 11:48 A.M.
% Added because the program would crash when fHeq was a negative number.
% Matlab returns a complex number as the answer to taking a negative number
% to the (1/3) power.  To keep the program from crashing, I take the
% absolute value of L when it is complex.  While the solution of the (1/3)
% power of a negative number should be negative, this way works; it returns
% the same final L and neq values as shifting the sferic does.
% BEGIN
if (~isreal(L)) L = abs(L); end
% END

K = calcK(L,model);
A = K*(3-K)/(K+1); % K = 1/Lambda_n (Tarcsai 1975 eq. 2)

t_vec_fit = D0 ./ sqrt(f_vec) .* (fHeq - A.*f_vec) ./ (fHeq - f_vec) + ...
   Dci ./ sqrt(f_vec) - T;

%DEBUG CODE
% figure
% plot(t_vec_fit,f_vec);
% hold on
% plot(t_vec,f_vec,'color','k');
% title(['D0: ',num2str(D0),', fHeq: ',num2str(fHeq),', T: ',num2str(T)]);
%%%%%%%

% disp(sprintf('DEBUG: D0 = %f\tfHeq = %f\tT = %f', D0, fHeq, T));

out = sum((t_vec - t_vec_fit).^2);
