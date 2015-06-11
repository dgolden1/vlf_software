function [dphi_mp_dt, p12_dphi_mp_dt, Ewv, Ewav, vBs] = get_dphi_mp_dt(V_SW, ByIMF, BzIMF, Pdyn)
% Derive dphi_mp_dt from Newell et al 2007 doi:10.1029/2006JA012015

% By Daniel Golden (dgolden1 at stanford dot edu) October 2011
% $Id$

Bt = sqrt(ByIMF.^2 + BzIMF.^2); % Transverse B
theta_c = atan2(ByIMF, BzIMF); % IMF clock angle
dphi_mp_dt = V_SW.^(4/3).*Bt.^(2/3).*abs(sin(theta_c/2).^(8/3));

if nargout > 1
  p12_dphi_mp_dt = sqrt(Pdyn).*dphi_mp_dt; % This function correlates best with Dst

  % Other solar wind coupling functions
  Ewv = abs(V_SW.^(4/3).*Bt.*sin(theta_c/2).^4.*Pdyn.^(1/6)); % [Vasyliunas et al, 1982]
  Ewav = abs(V_SW.*Bt.*sin(theta_c/2).^4); % [Wygant et al, 1983]
  vBs = V_SW.*max(0, BzIMF); % [Burton et al, 1975]
end
