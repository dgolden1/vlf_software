function whMakeNeqFile
% creates a text file which can be plotted by whMakeNeqPlot from tarcsai
% files selected by the user

global DF

destin = uigetdir(DF.destinPath);

if (destin(end) ~= filesep)
    destin = [destin filesep];
else
    destin = destin;
end


files = dir([destin '*_tarcsai_*.mat']);

if (strfind(files(1).name, 'tarcsai'))

    for n=1:length(files)
        load([destin files(n).name]);

        data(n,:) = [tarcsai_result.UT tarcsai_result.L tarcsai_result.neq];

    end

    sortrows(data,1);

    UTs = data(:,1)';
    Ls = data(:,2)';
    Neqs = data(:,3)';

    filename = [files(1).name(1:end-15) '_' files(end).name(1:end-15) '.txt'];

    n = 1;
    x = 1;

    while (~isempty(UTs))
       inds = find(UTs == UTs(1));
       if (length(inds) == 2)
           inds(3) = inds(2);
       elseif (length(inds) ==1)
           inds(2) = inds(1);
           inds(3) = inds(1);
       end
       L = [Ls(inds(1)) Ls(inds(2)) Ls(inds(3))];
       Neq = [Neqs(inds(1)) Neqs(inds(2)) Neqs(inds(3))];
       fileout(x,:) = [UTs(inds(1)) L mean(L) std(L) Neq mean(Neq) std(Neq)];
       n = max(inds) + 1;

       UTs = UTs(n:end);
       Ls = Ls(n:end);
       Neqs = Neqs(n:end);

       x = x + 1 ;
       n = 1;
    end

    dlmwrite([destin filename], fileout, 'delimiter', '\t', 'precision', 15, 'newline', 'pc');
	disp(['wrote ' destin filename] );
end
