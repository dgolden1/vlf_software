function K = calcK(L,model)
% CALCK	 Calculate K parameter (= f_Heq / f'n) defined in the following source:
%           C. G. Park, "Methods of determining electron concentrations in
%               the magnetosphere from nose whistlers", Technical Report No.
%               3454-1, Radioscience Laboratory, Stanford University, 1972.
%     Usage: K = calcK(L,model)
%     Input:  L: L-value
%             model: (text string) density models. Choices are:
%                   'DE-1','DE-2','DE-3','DE-4','CL','R-1','R-4','HY'.
%     Output: K: K parameter
%     Note: 1. If L is not listed in Table, a cubic spline interpolation is used.
%           2. The Hybrid model ('HY') calcultion in Park [1972] does not have
%              a value for L=8. The value for L=7 is repeated for L=8.
%           3. In 'R-1' model, values for L higher than 4 are the same as at L=4.

L_vec = [2, 2.5, 3, 4, 5, 6, 7, 8];

% The following data are taken from Park [1972]
switch model
case 'DE-1'
   K_vec = [2.821 2.733 2.708 2.696 2.703 2.708 2.721 2.737];
case 'DE-2'
   K_vec = [2.850 2.775 2.750 2.730 2.730 2.736 2.741 2.743];
case 'DE-3'
   K_vec = [2.836 2.740 2.709 2.696 2.703 2.708 2.721 2.737];
case 'DE-4'
   K_vec = [2.746 2.641 2.611 2.605 2.630 2.655 2.687 2.716];
case 'CL'
   K_vec = [2.644 2.475 2.385 2.297 2.253 2.229 2.220 2.213];
case 'R-1'
   K_vec = [2.8618 2.762 2.715 2.6728 2.6728 2.6728 2.6728 2.6728];
case 'R-4'
   K_vec = [2.677 2.500 2.403 2.297 2.236 2.196 2.164 2.147];
case 'HY'
   K_vec = [2.624 2.518 2.483 2.450 2.444 2.440 2.403 2.403];
otherwise
   error('Invalid density model.')
end

K = interp1(L_vec, K_vec, L, 'spline');
 

