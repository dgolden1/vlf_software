function ud=fwm_intermediate(nz,ul,dh,layers,dzl,dzh)
%FWM_INTERMEDIATE Find the wave amplitudes at intermediate points
% Usage:
%    ud=fwm_intermediate(nz,ul,dh,layers,dzl,dzh);
% Inputs (can have an optional third dimension N, e.g., when cycling over
% horizontal wave vectors):
%    nz         (4 x M x N) - vertical refractive index
%    {u|d}{l,h} (2 x {M|M-1} x N) - {upward|downward} mode amplitudes at
%       {lower|upper} boundaries of each layer; the second size is {M|M-1}
%       for {lower|upper} boundary values
%    layers  (Mi) - layer numbers corresponding to the output altitudes
%    dz{l|h} (Mi) - precalculated distanced from the output altitudes to the
%       nearest boundary {below|above}
% Output:
%    ud (4 x M x N) - up/down wave amplitudes at required altitudes
% NOTE: If layers(ki)==M, then dzhi(ki) is not be used (because the last
% layer has no upper boundary).
% See also: FWM_RADIATION, SOLVE_BOOKER_3D.
% Previous version: a fragment of EMITPLASMA_EXAMPLE_MEMSAVE
% Author: Nikolai G. Lehtinen

M=size(nz,2);
N=size(nz,3); % Additional size
if size(ul,2)~=M | size(dh,2)~=M-1 | size(ul,3)~=N | size(dh,3)~=N
    error('wrong size');
end
% Field at each output altitude
Mi=length(layers);
ud=zeros(4,Mi,N);
for ki=1:Mi
    k=layers(ki); % The layer number
    ui=exp(i*dzl(ki)*nz(1:2,k,:)).*ul(:,k,:);
    if k<M
        di=exp(-i*dzh(ki)*nz(3:4,k,:)).*dh(:,k,:);
    else
        di=repmat([0;0],[1 1 N]);
    end
    ud(:,ki,:)=cat(1,ui,di);
end
