function fileList = listFilesDeep(directory,prefix,suffix,deepFlag)
%syntax: fileList = listFilesDeep(directory,prefix,suffix,deepFlag)

a = '0';  
if(isempty(prefix))
    prefix = a(1:0);%creates empty string (strcmp will return 1)
end
if(isempty(suffix))
   suffix = a(1:0); 
end

yy = dir(directory);
y = {yy.name};

fileList = [];

for ii = 1:length(y)
    if(length(y{ii}) >= length([prefix suffix]) && ...
        strcmp(y{ii}(end-length(suffix)+1:end),suffix) && ... 
        strcmp(y{ii}(1:length(prefix)),prefix))
       
       fileList{length(fileList)+1} = fullfile(directory,y{ii});
    elseif(deepFlag && yy(ii).isdir && ~strcmp(yy(ii).name,'.') && ~strcmp(yy(ii).name,'..'))
        fileList = [fileList,listFilesDeep(fullfile(directory,y{ii}),prefix,suffix,deepFlag)];
    end
end
