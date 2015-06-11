function [y,u] = myConstants(x)
%
%c, 
switch x
    case 'c';
        y = 299792458;  
        u = '[m/s]';
        
    otherwise
        error('constant not recognized');
end
