function plot_burstiness_analysis_fullday
% Function to plot a 24-hour summary plot with labeled emissions, a la the
% synoptic summary emission characterizer

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'vlftool_24_hour_fcn'));

%% Set paths
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    source_dir = '/home/dgolden/temp/burstiness';
  otherwise
    error('Unknown hostname ''%s''', hostname(1:end-1));
end

db_filename = 'auto_chorus_hiss_db.mat';

%% Create spectrograms
startSec = 0;
endSec = 20;
bSavePlot = true;
numRows = 1;
f_lc = 0;
bContSpec = true;
bProc24 = false;
dbOffset = 0;
for kk = 1:length(ss_filename)
  vlftoolfcn(ss_filename{kk}, startSec, endSec, bSavePlot, output_dir, numRows, f_uc, f_lc, bContSpec, bProc24, dbOffset);
end
