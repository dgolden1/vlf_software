function outStruct = mat4LoadVar(filename,varName,sizes,offsets,precision)

%
%outStruct = mat4LoadVar(filename,varName,sizes,offsets,precision)
%
%Inputs:
%-------
%filename: MATLAB Version 4 .mat file
%varName: Cell array of variables to read in
%sizes: vector of size of each variable to read in
%offsets: vector of element (not byte) offset of each variable
%precision: cell array of precisions to read each variable in
%
%Output:
%-------
%outStruct: Struct of all variables
%
%Note: Using offsets for matrices may lead to an error
%if a column vector needs to be filled at the end.  Offsets
%recommended only vor vectors (row or column).  
%
%---Ryan Said, 4/28/05---

if(~iscell(varName) | ~iscell(precision))
    error('varName and precision must be cell arrays (even if length 1)')
end

L = length(varName);
if(length(sizes)~=L | length(offsets) ~=L | length(precision) ~=L)
    error('Lengths of varName, sizes, offsets, and precision must be equal')
end


outStruct = [];

fid = fopen(filename);
if(fid<0)
    warning(['Cannot open file ' filename]);
    return;
end

numVariables = length(varName);
numFound = 0;

%Load MOPT first and at end of loop b/c feof returns 1 AFTER last byte read
MOPT = fread(fid,1,'int32');    %only precision possibly nonzero
while(feof(fid)==0)
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
            error('Wrong .mat format: May not be Version 4 MAT file');
    end
    
    %Hack for chistochina data during July, 2004
    if(strcmp(thisVarName,'data') & strcmp(thisPrecision,'float'))
        bytesPerEntry = 2;
        thisPrecision = 'int16';
    end
    
    index = find(strcmp(thisVarName,varName));
    if(length(index)==1)
        numFound = numFound + 1;
        origSize = mrows*ncols;   
        if(offsets(index)> origSize)
            warning(['Offsets too big for variable ' varName{index}]);
             eval(['outStruct.' varName{index} ' = [];']);
            fseek(fid,mrows*ncols*bytesPerEntry,0);
             MOPT = fread(fid,1,'int32');
            continue;
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
        
        eval(['outStruct.' varName{index} ' = fread(fid,[' num2str(mrows) ',' num2str(ncols) '],''' thisPrecision '=>' precision{index} ''');']);
        fseek(fid,(origSize - mrows*ncols-offsets(index))*bytesPerEntry,0);
    else
        fseek(fid,mrows*ncols*bytesPerEntry,0);
    end
    MOPT = fread(fid,1,'int32');    %only precision possibly nonzero
end
fclose(fid);

if(numFound ~= numVariables)
    warning('Not all variables found');
end
