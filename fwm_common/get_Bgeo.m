function [oarg1,Babs,thB,phB]=get_Bgeo(varargin)
%GET_BGEO Geomagnetic field in T
% Auxiliary parsing function, to be used for GET_PERM, GET_WARM_PERM
% Usage:
%    keys=get_Bgeo('get_keys');
%    [Bgeo,Babs,thB,phB]=get_Bgeo(h[,options]);
% Inputs:
%    h - array of length M, altitudes in km
% Options:
%    Bgeo - array of 3 components of geomagnetic field
%    Babs - |Bgeo|, default = 5e-5
%    thB, phB - polar and azimuthal angle (default=vertical downward)
%    Bgeo_load - IGRF output file with the field as a function of h
%       (default='')
% Outputs:
%    keys - a list of available options
%    Bgeo - M x 3 array of geomagnetic field components
%    Babs - |Bgeo|
%    thB, phB - polar and azimuthal angle
% See also: GET_WARM_PERM, GET_PERM
% Author: Nikolai G. Lehtinen
global global_dir
if isempty(global_dir)
    loadconstants
end
keys={'Bgeo','Bgeo_load','Babs','thB','phB'};
[s,options]=parsearguments(varargin,1,keys);
if ischar(s)
    switch s
        case 'get_keys'
            oarg1=keys;
        otherwise
            error(['unknown command: ' s])
    end
    return
else
    h=s;
end
M=length(h);
Bgeo=getvaluefromdict(options,'Bgeo',[]);
if isempty(Bgeo)
    % Try Babs and angles
    Babs=getvaluefromdict(options,'Babs',[]);
    if isempty(Babs)
        Bgeo_load=getvaluefromdict(options,'Bgeo_load','');
        if ~isempty(Bgeo_load)
            if strcmp(Bgeo_load,'default')
                tmp=load(fullfule(global_dir, ['HAARPgeomag.txt']));
            else
                tmp=load(Bgeo_load);
            end
            hB=tmp(:,1);
            BhB=[tmp(:,5) tmp(:,4) -tmp(:,6)]*1e-9;
            % Interpolate B
            Bgeo=interp1(hB,BhB,h); % Do not use "B" -- used for wave propagation!
            needthB=0;
        else
            Babs=5e-5;
            needthB=1;
        end
    else
        needthB=1;
    end
    if needthB
        thB=getvaluefromdict(options,'thB',pi);
        phB=getvaluefromdict(options,'phB',0);
        Bgeo=[sin(thB)*cos(phB)*Babs sin(thB)*sin(phB)*Babs cos(thB)*Babs];
    end
end
if length(Bgeo(:))==3
    Bgeo=repmat(Bgeo,M,1);
end
oarg1=Bgeo;
if nargout>1
    Babs=sqrt(sum(Bgeo.^2,2));
    thB=acos(Bgeo(:,3)./Babs);
    thB(find(Babs==0))=0;
    phB=atan2(Bgeo(:,2),Bgeo(:,1));
end
