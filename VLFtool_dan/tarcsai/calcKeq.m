function Keq = calcKeq(L,model)
% CALCKEQ   Calculate Keq parameter (related to neq) defined in:
%           C. G. Park, "Methods of determining electron concentrations in
%               the magnetosphere from nose whistlers", Technical Report No.
%               3454-1, Radioscience Laboratory, Stanford University, 1972.
%     Usage: K = calcKeq(L,model)
%     Input:  L: L-value
%             model: (text string) density models. Choices are:
%                   'DE-1','DE-2','DE-3','DE-4','CL','R-1','R-4','HY'.
%     Output: Keq: Keq parameter
%     Note: 1. If L is not listed in Table, a cubic spline interpolation is used.
%           2. The Hybrid model ('HY') calcultion in Park [1972] does not have
%              a value for L=8. The value for L=7 is repeated for L=8.
%           3. In 'R-1' model, values for L higher than 4 are the same as at L=4.

L_vec = [2, 2.5, 3, 4, 5, 6, 7, 8];

% The following data are taken from Park [1972]
switch model
case 'DE-1'
	Keq_vec = [27.55 24.34 23.58 23.53 24.06 24.70 25.49 26.34];
case 'DE-2'
	Keq_vec = [29.60 26.62 25.74 25.30 25.43 25.72 26.08 26.44];
case 'DE-3'
	Keq_vec = [28.08 24.62 23.70 23.58 24.10 24.73 25.50 26.35];
case 'DE-4'
	Keq_vec = [22.78 19.65 19.10 19.70 21.02 22.49 24.15 25.90];
case 'CL'
	Keq_vec = [16.79 12.34 10.46 8.782 8.052 7.680 7.535 7.481];
case 'R-1'
	Keq_vec = [29.776 25.416 23.587 22.044 22.044 22.044 22.044 22.044];
case 'R-4'
	Keq_vec = [18.45 13.38 11.13 8.939 7.832 7.140 6.687 6.372];
case 'HY'
	Keq_vec = [16.10 13.34 12.43 11.69 11.55 11.54 9.810 9.810];
otherwise
   error('Invalid density model.')
end

Keq = interp1(L_vec, Keq_vec, L, 'spline');
 
