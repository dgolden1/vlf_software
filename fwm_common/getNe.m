function Ne0=getNe(h0,profile)
if nargin<2
    profile=[];
end
Ne0=getSpecies('Ne',h0,profile);
