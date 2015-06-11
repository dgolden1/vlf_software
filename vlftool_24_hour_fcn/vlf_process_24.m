function vlf_process_24(bNoDFUpdate)
% Make a 24-hour synoptic spectrogram

% $Id$

if ~exist('bNoDFUpdate', 'var') || isempty(bNoDFUpdate)
	bNoDFUpdate = false;
end

global DF;

if ~bNoDFUpdate
	updateDF;
end

DF.process24 = 1;

status = 'Process';

while( strcmp(status, 'Process') )
  isvalid = vlfProcess;
  if( ~isvalid )
    DF.process24 = 0;
    return;
  end;

  if( length( DF.h_ax ) == 96 || bNoDFUpdate)
    status = 'Done';
  else
%     status = questdlg('Insert next disc', 'Process 24', 'Process', 'Done', 'Process');
	
	new_disc_dir = uigetdir(DF.sourcePath, 'Insert next disc');
	if ischar(new_disc_dir)
		status = 'Process';
		DF.sourcePath = fullfile(new_disc_dir, filesep);
		h = findobj('Tag', 'sourcePath');
		set(h, 'String', DF.sourcePath );
	else
		status = 'Done';
	end
  end;

  if( strcmp( status, 'Done' ) )
    if( DF.bSavePlot )
      vlfSavePlot;
    end;
    DF.h_ax = [];
    DF.h_cb = [0 0];
    DF.process24 = 0;

  else
    DF.process24 = DF.process24 + 1;
  end;
end;
