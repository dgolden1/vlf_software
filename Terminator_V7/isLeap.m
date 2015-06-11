function out = isLeap(year)

out = 0;
if(mod(year,4)==0)
    out = 1;
end
if(mod(year,100)==0)
    out = 0;
end
if(mod(year,400)==0)
    out = 1;
end
