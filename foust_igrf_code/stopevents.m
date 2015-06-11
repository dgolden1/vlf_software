function [value,isterminal,direction] = stopevents(t,y,minalt,maxalt)

  value=1;
  isterminal = 1;
  direction = 0;
  if( norm(y)-6371.2 < minalt )
    value = 0;
  end
  if( norm(y)-6371.2 > maxalt )
    value = 0;
  end
  
