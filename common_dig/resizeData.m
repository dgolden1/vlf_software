function new_filename = resizeData(folder, filename, varName, sizes, offsets, increment, new_suffix, b_use_newdate)
% syntax: new_filename = resizeData(folder, filename, varName, sizes, offsets, increment, new_suffix, b_use_newdate)
%
%
% Inputs:
% -------
% filename: MATLAB Version 4 .mat file
% varName: Cell array of variables to read in
% sizes: vector of size of each variable to read in
% offsets: vector of element (not byte) offset of each variable
% increment: amount by which to increment hour, minute and second of "start
%  time" variables
% new_suffix: suffix to be appended to new filename
% b_use_newdate: true
%
% Output:
% -------
% new_filename: filename of resized file
%
% Note: Using offsets for matrices may lead to an error
% if a column vector needs to be filled at the end.  Offsets
% recommended only vor vectors (row or column).  

%---Ryan Said, 4/28/05---
%
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
if ~exist('increment', 'var') || isempty(increment)
    increment = zeros(1,length(varName));
end
if ~exist('new_suffix', 'var') || isempty(new_suffix)
    new_suffix = '';
end
if ~exist('b_use_newdate', 'var') || isempty(b_use_newdate)
	b_use_newdate = false;
end

if(~iscell(varName))
    error('varName and precision must be cell arrays (even if length 1)')
end

L = length(varName);
if(length(sizes)~=L || length(offsets) ~=L)
    error('Lengths of varName, sizes, offsets, and precision must be equal')
end

%% Open old file
[fid, msg] = fopen(filename);
if(fid < 0)
    error('Cannot open file ''%s'' (%s)', filename, msg); 
    return;
end

%% Make the new filename
if ~exist(folder, 'dir')
	mkdir(folder);
end
[f,n,e] = fileparts(filename);
if ~b_use_newdate
	new_filename = fullfile(folder,[n e]);
else
	[old_datenum, junk, station_code, channel_num] = get_bb_fname_datenum(filename, false);
	old_datevec = datevec(old_datenum);
	new_datevec = [old_datevec(1:3), old_datevec(4:6) + increment(1:3)];
	new_datenum = datenum(new_datevec);

	% Traditionally synoptic N/S files have a suffix of _002 and E/W files
	% have a suffix of _003. Broadband files are _000 and _001,
	% respectively.
	% channel_num is 1 (N/S) or 2 (E/W)

	if channel_num == 0
		new_channel_suffix = '_002';
	elseif channel_num == 1
		new_channel_suffix = '_003';
	elseif channel_num == -1
		% Interleaved
		new_channel_suffix = '';
	else
		error('Weird channel number (''%d'')', channel_num);
	end
	
	% Old versions of Matlab switch the day and hour when datestringing
	% yymmddHHMMSS!
	new_filename = fullfile(folder, [station_code, datestr(new_datenum, 'yymmdd'), datestr(new_datenum, 'HHMMSS'), new_channel_suffix, e]);
end

%change the suffix to new_suffix
[pathstr, name, ext] = fileparts(new_filename);
name = [name new_suffix];
new_filename = fullfile(pathstr, [name ext]);
% new_filename(end-length(new_suffix)+1:end) = new_suffix;

%% Open new file for writing
if strcmp(filename, new_filename)
	error('Source and destination filenames are the same! (''%s'')', new_filename);
elseif exist(new_filename, 'file')
	fprintf('Overwriting output file %s.\n', new_filename);
% 	error('Output file (''%s'') exists!', new_filename);
end

[fidNew, msg] = fopen(new_filename,'w');
if(fidNew < 0)
    error('Cannot open file ''%s'' (%s)', filename, msg); 
    return;
end

%% Write new file
numVariables = length(varName);
numFound = 0;

%Load MOPT first and at end of loop b/c feof returns 1 AFTER last byte read
MOPT = fread(fid,1,'int32');    %only precision possibly nonzero
while(feof(fid)==0)
    fwrite(fidNew,MOPT,'int32');
    mrows = fread(fid,1,'int32');
    ncols = fread(fid,1,'int32');
    imagf = fread(fid,1,'int32');   %VLF - never used
    namelen = fread(fid,1,'int32');
    varNameTemp = fread(fid,namelen,'char=>char');
    thisVarName = varNameTemp(1:end-1)';    %zero delimiter
    
    
    switch MOPT
        case 0
            thisPrecision = 'double';
            bytesPerEntry = 8;
        case 10
            thisPrecision = 'float';
            bytesPerEntry = 4;
        case 20
            thisPrecision = 'int32';
            bytesPerEntry = 4;
        case 30
            thisPrecision = 'int16';
            bytesPerEntry = 2;
        case 40
            thisPrecision  = 'uint16';
            bytesPerEntry = 2;
        case 50
            thisPrecision = 'char';
            bytesPerEntry = 1;
        otherwise
            fclose(fidNew);
            delete(new_filename);
            error('Wrong .mat format: May not be Version 4 MAT file');
    end
    
    %Hack for chistochina data during July, 2004
    if(strcmp(thisVarName,'data') && strcmp(thisPrecision,'float'))
        bytesPerEntry = 2;
        thisPrecision = 'int16';
    end
    
    index = find(strcmp(thisVarName,varName));
    if(length(index)==1)    %modify data:

        numFound = numFound + 1;
        origSize = mrows*ncols;   
        if(offsets(index)> origSize)
            fclose(fidNew);
            delete(new_filename);
            error(['Offsets too big for variable ' varName{index}]);
        end    
        
        
        fseek(fid,offsets(index)*bytesPerEntry,0);
        
        if(origSize < offsets(index) + sizes(index))
            sizes(index) = origSize - offsets(index);
            warning(['offsets + sizes too big for variable ' varName{index} '.  Reducing size to ' num2str(sizes(index))]); 
        end
            
        mrows = min(mrows,sizes(index));
        if(mrows > 0)
            ncols = min(ncols,ceil(sizes(index)/mrows));
        else
            ncols = 1;
        end

        fwrite(fidNew,mrows,'int32');
        fwrite(fidNew,ncols,'int32');
        fwrite(fidNew,imagf,'int32');
        fwrite(fidNew,namelen,'int32');
        fwrite(fidNew,varNameTemp,'char');
        if(increment(index) ~= 0)
           fwrite(fidNew,double(fread(fid,[mrows,ncols],thisPrecision)) + increment(index),thisPrecision); 
        else
            fwrite(fidNew,fread(fid,[mrows,ncols],thisPrecision),thisPrecision);
        end
        fseek(fid,(origSize - mrows*ncols-offsets(index))*bytesPerEntry,0);
    else
        %Leave this data segment alone:
    fwrite(fidNew,mrows,'int32');
    fwrite(fidNew,ncols,'int32');
    fwrite(fidNew,imagf,'int32');
    fwrite(fidNew,namelen,'int32');
    fwrite(fidNew,varNameTemp,'char');
    fwrite(fidNew,fread(fid,mrows*ncols,thisPrecision),thisPrecision);
    end
    MOPT = fread(fid,1,'int32');    %only precision possibly nonzero
end
fclose(fid);
fclose(fidNew);

if(numFound ~= numVariables)
    warning('Not all variables found'); %#ok<*WNTAG>
end
