function [time, data, f_center, f_bw, f_lim] = read_dfb_cdf(filename, varargin)
% [time, data, f_center, f_bw] = read_dfb_cdf(filename, 'param', value)
% Parse data from a THEMIS digital fields board (DFB) CDF file
% 
% INPUTS
% filename: CDF filename
% 
% PARAMETERS
% 'var': DFB parameter to read.  This should correspond to a variable
% name in the CDF file.  Reasonable choices may be:
% 'fb_scm1' (filter bank search coil magnetometer 1, default)
% 'fb_scm2'
% 'fb_scm3'
% 'fb_eac12' (AC coupled e-field for antenna 1/2)
% 'fb_eac34'
% 'fb_eac56'
% 'fb_edc12' (DC coupled e-field for antenna 1/2)
% 'fb_eac34'
% 'fb_eac56'


% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('var', 'fb_scm1');
p.parse(varargin{:});
var = p.Results.var;

%% Extract variables
info = cdfinfo(filename);

% The three letter probe identifier precedes the variable name
probe_name = info.Variables{1, 1};
probe_name = probe_name(1:3);
assert(strcmp(probe_name(1:2), 'th'));

[data, time] = cdf_get_data(filename, [probe_name '_' var], [probe_name '_fbk_epoch0'], [probe_name '_' var '_time']);
if isempty(data)
  error('read_dfb_cdf:variableNotFound', 'CDF file %s does not contain variable %s', filename, [probe_name '_' var]);
end

f_center = cdf_get_data(filename, [probe_name '_fbk_fcenter']);
f_bw = cdf_get_data(filename, [probe_name '_fbk_fband']);

% Get upper and lower bin frequencies
if ~isempty(strfind(var, 'eac'))
  error('I need to make sure this works right for AC coupled E-field data because the sampling rate is doubled');
end
[f_lim(1,:), f_lim(2,:)] = get_f_limits(f_center);

function [f_l, f_h] = get_f_limits(f_c)
%% Get frequency limits from center frequency and bandwidth
% Pick from Cully et al (2008), Table 6 (doi: 10.1007/s11214-008-9417-1)

% NOTE: in the table in Cully 2008, the highest frequency channel is listed
% as extending to 5994 Hz; however, the SCM instrument is sampled at 8
% kS/sec, which means that the actual detectable frequency is 4000 kHz.

% The EFI instrument can be sampled at either 8 kS/sec (DC coupled) or 16
% kS/sec (AC coupled); in the former case, the bandwidth is the same as the
% SCM instrument, which is the odd indices below. In the latter case, the
% bandwidth is twice the frequencies of the even indices.
f_l_vec = [1390 631 316 159 80.2 40.2 20.1 10.1 5.04 2.52 1.26 0.63];
f_c_vec = [2689 1149 572 287 144.2 72.3 36.2 18.1 9.05 4.53 2.26 1.13];
f_h_vec = [5994 1836 904 453 227.4 113.9 57.0 28.5 14.26 7.13 3.57 1.78];

idx = interp1(f_c_vec, 1:length(f_c_vec), f_c, 'nearest', 'extrap');
%idx = nearest(f_c, f_c_vec);
f_l = f_l_vec(idx);
f_h = f_h_vec(idx);
  

% f_l = 0.5*(-f_bw + sqrt(f_bw.^2 + 4*f_c.^2));
% f_h = f_l + f_bw;
