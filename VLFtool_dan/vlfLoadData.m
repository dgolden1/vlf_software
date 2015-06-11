function vlfLoadData( filename, pathname, whichSec )
% Extracts header information from the broadband file
% 
% Commented by Daniel Golden (dgolden1 at stanford dot edu) April 2007

% $Id$

global DF;

if( nargin < 3 )

	whichSec(1) = DF.startSec;
	whichSec(2) = DF.endSec;

end;

DF.bbrec = vlfExtractBB( pathname,  filename, whichSec(1), whichSec(2), 0 );

%load(fullfile(pathname, filename));
%DF.bbrec = bbrec;

