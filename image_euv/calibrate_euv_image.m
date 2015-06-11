function euv_img_cal = calibrate_euv_image(euv_img, euv_img_datenum)
% euv_cal = calibrate_euv_image(euv_img, euv_img_datenum)
% Return calibrated EUV image from uncalibrated image
% Formulas from personal correspondence with M. Spasojevic, May 2008

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

persistent solar
if isempty(solar)
	load('solar304.mat');
end

solar_factor = interp1(solar.UT, solar.solar304, euv_img_datenum);

euv_img_cal = euv_img * 2.76e19 / solar_factor;
