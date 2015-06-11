function result = inFolder(filename,foldername)


disp(nargchk(1, 2, nargin))  ;
if(nargin==2)
    [w,current_dir] = dos('chdir');
    dos(['cd ' foldername ]);
    [w,s] = dos('dir');
    matches =findstr(filename,s);
    if(length(matches)>0)
        result = 1;
    else
        result = 0;
    end
    dos(['cd ' current_dir]);
else
    [w,s] = dos('dir');
    matches =findstr(filename,s);
    if(length(matches)>0)
        result = 1;
    else
        result = 0;
    end
end

