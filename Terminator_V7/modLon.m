function lonOut = modLon(lonIn);

%mod's angle to -180<lonOut<180

lonOut = mod(lonIn,360);
if(lonOut>180)
    lonOut = lonOut-360;
end
