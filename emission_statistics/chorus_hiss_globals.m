function [CHORUS_B_MIN CHORUS_B_MAX HISS_B_MIN HISS_B_MAX] = chorus_hiss_globals
% Set global values for what burstiness levels define chorus and hiss
% 
% Determined using Dan's eyeballs staring at the chorus and hiss emission
% catalog (see $danmatlabroot/synoptic_summary_emission_characterizer/create_event_catalog.m)

% By Daniel Golden (dgolden1 at stanford dot edu) Feburary 2010
% $Id$

% % Values used through Feb 11, 2010
% CHORUS_B_MIN = 0.25;
% CHORUS_B_MAX = 1;
% HISS_B_MIN = -0.3;
% HISS_B_MAX = 0.15;

% % New values as of Feb 11, 2010, based on audit of 2001 data
% CHORUS_B_MIN = 0.2;
% CHORUS_B_MAX = 1;
% HISS_B_MIN = -0.3;
% HISS_B_MAX = 0.04;

% Compromise values
CHORUS_B_MIN = 0.2;
CHORUS_B_MAX = 1;
HISS_B_MIN = -0.3;
HISS_B_MAX = 0.1;

