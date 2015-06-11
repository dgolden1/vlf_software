function status = vlfProcess( command, filenames )


% $Id$

error(nargchk(0, 2, nargin));

% command = 1 : interactive select files
if( nargin == 0 )
  command = 0;
end;

global DF;

pathname = [];
filename = [];

if exist('filenames', 'var') && ~isempty(filenames)
  filename = cellfun(@just_filename, filenames, 'UniformOutput', false);
	pathname = fileparts(filenames{1});
elseif( command == 1 )
   % ignore wildcard
  [fname, pathname] = uigetfile(DF.sourcePath, '*.mat', 'MultiSelect', 'On');
  if( pathname == 0 )
    return;
  end
  
  % Redo the files and start offsets to select data records on the
  % traditional synoptic minutes (5, 20, 35, 50 min after the hour)
  if DF.bForceEvery15
    duration = DF.endSec(1) - DF.startSec(1);
    [filenames_out, file_offsets] = get_synoptic_offsets('pathname', pathname, 'filenames_in', fname, ...
      'start_sec', DF.startSec(1), 'duration', duration);
    fname = filenames_out;
    DF.startSec = file_offsets;
    DF.endSec = DF.startSec + duration;
  end
  
  DF.sourcePath = fullfile(pathname, filesep);
  h = findobj('Tag', 'sourcePath');
  set(h, 'String', DF.sourcePath );

  if( iscell(fname) )
    filename = fname;
  else
    filename{1} = fname;
  end;
else
  d = [];
  for( k = 1:length( DF.wildcard ) )
    d = [d; dir( fullfile(DF.sourcePath, DF.wildcard{k}) )];
  end;
  
  if( ~isempty(d) )
    filename = {d.name};
  end;
  pathname = DF.sourcePath;
end;

if (isempty( filename ) | filename{1} == 0 )
  disp('No files to process');
  status = 0;
  return;
end;

filenames_original = filename;
filename = vlfRemoveRedundantFiles(filenames_original);
if isempty(filename) && ~isempty(filenames_original)
	error('All files removed by vlfRemoveRedundantFiles');
end

[filename, ii] = sort(filename);

numPlots = length(filename);
if( DF.process24 )
  DF.maxPlots = 96;
elseif( ~isfield(DF, 'maxPlots') || DF.maxPlots == -1 )
  DF.maxPlots = numPlots;
end;
numPages = ceil( numPlots / DF.maxPlots );

sii = 1;

if isscalar(DF.startSec), DF.startSec = repmat(DF.startSec, size(filename)); end
if isscalar(DF.endSec), DF.endSec = repmat(DF.endSec, size(filename)); end

for( m = 1:numPages )

	eii = sii+DF.maxPlots-1;
	if( eii > numPlots )
		eii = numPlots;
	end;
	DF.filename = filename([sii:eii]);
	DF.pathname = pathname;
	DF.numPlots = length(DF.filename);

	vlfProcessPage;

	if DF.bSavePlot
	  vlfSavePlot;
	end;

	sii = eii+1;

end;

status = 1;
