%calculate_pts.m

HHprogress = findobj(gcf,'tag','progress');

compTime = calculateArc(gcf,0);
if(compTime>0)
set(HHprogress,'string',['Done! (' num2str(compTime) ' seconds).']);

end



