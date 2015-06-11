function copyBBFiles(readDirectory,deepFlag,writeDirectory)
%sytnax: copyBBFiles(readDirectory,deepFlag,writeDirectory)
%
%example:
%copyBBFiles('H:\',1,'S:\raw_data\broadband');
%
%Currently assumes station name is at least 6 characters at each site
%Assigns correct station name based on names on vlf-alexandria
%If station missing in switch statement, just add it!
%Compatible with DAQ code data formats 2002 and 2005
%If deepFlag is 1, then it searches all subfolders of readDirectory as
%well.  
%
% Ryan Said, Sept 11, 2007

fileList = listFilesDeep(readDirectory,'','.mat',deepFlag);

copyCount = 0; tic;

for ii = 1:length(fileList);
    
    warning off;
    FsCheck2005 = mat4LoadVar(fileList{ii},{'Fs'},1,0,{'double'}); %version 2005
    FsCheck2002 = mat4LoadVar(fileList{ii},{'channel_sampling_freq'},1,0,{'double'}); %version 2005
    warning on;
    
    if(isempty(FsCheck2005) & isempty(FsCheck2002))
        disp(['Unrecognized .mat file: ' fileList{ii} ', moving on to next file']);
        continue;
    end
    
    if(~isempty(FsCheck2005))
        temp = mat4LoadVar(fileList{ii},{'station_name'},6,0,{'char'});     
    end
    if(~isempty(FsCheck2002))
        temp = mat4LoadVar(fileList{ii},{'siteName'},6,0,{'char'});
    end
    station_name = temp.station_name(:)';
    
    station = '';
    
    if(length(station_name) < 6)
        disp('Station name has less than 6 characters - not yet supported.  Contact Ryan Said');
        disp(['Station name: ' station_name]);
    end
    
    if(length(station_name)>=6)
        switch lower(station_name(1:6))
            case 'chisto'
                station = 'chistochina';
            case 'palmer'
                station = 'palmer';
            case 'ketchi'
                station = 'ketchikan';
            case 'midway'
                station = 'midway';
            case 'nathan'
                station = 'nathaniel_b_palmer';
            case 'taylor'
                station = 'taylor';
            case 'ascens'
                station = 'ascension';
            case 'lmscfb'
                station = 'santa_cruz';
            otherwise
                disp(['Unrecognized station: ' station_name ', moving on to next file']);
                station = '';
        end
    end

    if(~isempty(station))   
        ts = mat4LoadVar(fileList{ii},{'start_year','start_month','start_day',...
            'start_hour','start_minute','start_second'},[1 1 1 1 1 1],[0 0 0 0 0 0],...
            {'double','double','double','double','double','double'});

        T = [ts.start_year ts.start_month ...
            ts.start_day ts.start_hour ts.start_minute ts.start_second];

        folder_date_string = sprintf('%04d\\%02d_%02d',T(1),T(2),T(3));
        [PATHSTR,NAME,EXT,VERSN] = fileparts(fileList{ii}); 
        
        newFilename = fullfile(writeDirectory,station,folder_date_string,[NAME EXT]);
        [PATHSTR,NAME,EXT,VERSN] = fileparts(newFilename);
        warning off; mkdir(PATHSTR); warning on;
        
        
        dos(['copy /Y /B ' fileList{ii} ' ' newFilename]); 
        copyCount = copyCount + 1;
    end

end

disp(['Copy Count = ' num2str(copyCount) ' Files']); toc;
