function [L_shells,n_s] = Lread(L)

%L is a cell array

for i = 1:length(L)
    shell = deblank(L{i});
    len = length(shell);
    if(strcmpi('s',shell(len)))
        n_s(i) = 1;
        L_shell =  str2num(shell(1:len-1));
        if(length(L_shell)==0)
            error('unrecognized format');
        end
        L_shells(i) = L_shell;
    elseif(strcmpi('n',shell(len)))
        n_s(i) = -1;
        L_shell =  str2num(shell(1:len-1));
        if(length(L_shell)==0)
            error('unrecognized format');
        end
        L_shells(i) = L_shell;
    else
        error('unrecognized format');
    end
end
