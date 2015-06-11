function whNeqPlotFcn (filename)
% Plots Neq versus time for data found in the function argument filename.
% Each row of the file should be formatted as follows
% 
% yyyy-mm-dd HH:MM:SS L1 L2 L3 Avg(L1,L2,L3) StdDev(L1,L2,L3) Neq1 Neq2 Neq3 Avg(Neq1,Neq2,Neq3) StdDev(Neq1,Neq2,Neq3) DST
% 
% The first entry is the year, month and day the whistler occured.  The
% second entry is the hour, minute and second the whistler began.  L1, L2,
% and L3 are the L values returned by the TARCSAI analysis on three
% different tracings of the whistler.  Avg(L1,L2,L3) is the average of the
% three and likewise StdDev(L1,L2,L3) is the standard deviation of the
% three.  The same pattern is used for the Neq values.  DST is the DST
% value at the time of the whistler as given by Kyoto World Data Center.
%
% Two plots are displayed.  The top graph a scatter plot of Neq versus time 
% on a log scale.  Data points are color coded according to their L value.
% The bottom plot is of the DST values for the points in the Neq plot.

% read in file
fid = fopen(filename);
Data = textscan(fid, '%s %s %f %f %f %f %f %f %f %f %f %f %d');
fclose(fid);

UT = [];

% create time vector for all data
for n=1:length(Data{1})
    UT = [UT datenum(strcat(Data{1}(n),Data{2}(n)),'yyyy-mm-ddHH:MM:SS')];
end


Neq = [Data{11}];
StdDev = [Data{12}];
DST = [Data{13}];

name = filename(1:end-4);

name(find(name == '_')) = ' ';

L = 1.5 ;
AvgL = Data{5};
colors = ['y' 'm' 'c' 'r' 'g' 'b' 'w' 'k'];
colorindex = 1;

figure
h = subplot(211);
title(['Neq vs UT for ', name])
xlabel('UT')
ylabel('Neq')
set(h,'NextPlot','add');

hh = subplot(212);

title(['DST vs UT for ', name])
xlabel('UT')
ylabel('DST')
set(hh,'NextPlot','add');

legendstrings = {};

while (L<=3.5)
    inds = find(AvgL <= L & AvgL > (L-.25));
    if (~isempty(inds))
        axes(h);
        errorbar(UT(inds),Neq(inds),StdDev(inds),'LineStyle','none',...
            'Marker', '.','MarkerFaceColor',colors(colorindex),'Color',colors(colorindex));
        set(gca,'YScale','log');
        axes(hh);
        plot(UT(inds),DST(inds),'LineStyle','none', 'Marker', 'o',...
            'MarkerEdgeColor', colors(colorindex),'MarkerFaceColor',colors(colorindex));
        colorindex = colorindex + 1;
        legendstrings{end+1} = [num2str(L-.25) ' < L <= ' num2str(L)];
    end
    L = L + .25;
        
end

legend (h, legendstrings, 'Location','SouthOutside');

xticks = datestr(get(h,'xtick'));
if (length(xticks) > 13)
    xticks = whSetTickLabels(get(h,'xtick'));
else 
    xticks = xticks(:,1:6);
end
set(h,'xticklabel',xticks);

xlimits = get(h,'XLim');
xtickmarks = get(h,'xtick');


set(hh,'XLim',xlimits);
set(hh,'xtick',xtickmarks);

set(hh,'xticklabel',xticks);

