function bbrec = vlfLoadData( filename, pathname, startSec, endSec, bCombineChannels )
% bbrec = vlfLoadData( filename, pathname, startSec, endSec, bCombineChannels )

% Originally by Maria Spasojevic
% Modified by Daniel Golden (dgolden1 at stanford dot edu) December 2009
% $Id$

global DF;

if nargin < 3
	startSec = DF.startSec;
	endSec = DF.endSec;
end
if nargin < 5
	bCombineChannels = DF.bCombineChannels;
end

bbrec = vlfExtractBB( pathname,  filename, startSec, endSec, 0, bCombineChannels );
DF.bbrec = bbrec;

if( isempty( bbrec.data ) )
  disp('** Empty data record -- file corrupt?? **');
end;

