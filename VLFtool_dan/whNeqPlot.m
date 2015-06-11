function whNeqPlot(filename)
% Plots Neq versus time for data found in the function argument filename.
% Each row of the file should be formatted as follows
% 
% datenum L1 L2 L3 Avg(L1,L2,L3) StdDev(L1,L2,L3) Neq1 Neq2 Neq3 Avg(Neq1,Neq2,Neq3) StdDev(Neq1,Neq2,Neq3)
% 
% The first entry is the datenum representation fo the time the whistler occured.  
% L1, L2, and L3 are the L values returned by the TARCSAI analysis on three
% different tracings of the whistler.  Avg(L1,L2,L3) is the average of the
% three and likewise StdDev(L1,L2,L3) is the standard deviation of the
% three.  The same pattern is used for the Neq values.  
%
% Garphs a scatter plot of Neq versus time on a log scale.  
% Data points are color coded according to their L value.

% read in file
fid = fopen(filename);
Data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f');
fclose(fid);

UT = [Data{1}];
Neq = [Data{10}];
StdDev = [Data{11}];

name = [datestr(UT(1), 'yyyy mmm dd HH:MM:SS') ' to ' datestr(UT(end), 'yyyy mmm dd HH:MM:SS')];

L = 1.5 ;
AvgL = Data{5};
colors = ['y' 'm' 'c' 'r' 'g' 'b' 'w' 'k'];
colorindex = 1;

figure
h = axes;
title(['Neq vs UT for ', name])
xlabel('UT')
ylabel('Neq')
set(h,'NextPlot','add');

legendstrings = {};

while (L<=3.5)
    inds = find(AvgL <= L & AvgL > (L-.25));
    if (~isempty(inds))
        axes(h);
        errorbar(UT(inds),Neq(inds),StdDev(inds),'LineStyle','none',...
            'Marker', '.','MarkerFaceColor',colors(colorindex),'Color',colors(colorindex));
        set(gca,'YScale','log');
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

for n = 1:length(UT)
    
   disp(['UT Time: ',datestr(UT(n))])
   disp(['Avg L ' , num2str(AvgL(n)), ' Std Dev ', num2str(Data{6}(n))])
   disp(['Avg Neq ',num2str(Neq(n)),' Std Dev ', num2str(StdDev(n))]) 
   disp('-----')
    
end
