function [ii,dzl,dzh]=fwm_get_layers(z,zi);
%FWM_GET_LAYERS Prepare the indeces of layers for FWM
% Usage:
%   [layers,dzl,dzh]=fwm_get_layers(z,zi);
% z - boundaries between layers
% zi - the output points
% layers - numbers of layers of output points
% dz{l,h} - distance to the nearest boundary {below|above} the output point
Mi=length(zi);
M=length(z);
ii=zeros(1,Mi);
dzl=nan(1,Mi); dzh=dzl;
for ki=1:Mi
    % The altitudes
    zi0=zi(ki);
    k=max(find(z<=zi0)); % Which layer are we in?
    ii(ki)=k;
    dzl(ki)=zi0-z(k); % Distance to the boundary below
    if k<M
        dzh(ki)=z(k+1)-zi0; % Distance to the boundary above
    end
end
