function result=fwm_axisymmetric_aux(np_arg,zd,eground,perm,...
    ksa,np0,Ie0,Im0,EHfu0,EHfd0,...
    kia,dzl,dzh)
%FWM_AXISYMMETRIC_AUX Auxiliary function as an argument to BESTGRID
point_source=isempty(np0);
if point_source
	% Point source - just repeat the matrix I0 (3 x Ms)
    if isempty(Ie0)
        Ie0i=[];
    else
        Ie0i=repmat(Ie0,[1 1 length(np_arg)]);
    end
    if isempty(Im0)
        Im0i=[];
    else
        Im0i=repmat(Im0,[1 1 length(np_arg)]);
    end
    if isempty(EHfu0)
        EHfu0i=[];
    else
        EHfu0i=repmat(EHfu0,[1 length(np_arg)]);
    end
    if isempty(EHfd0)
        EHfd0i=[];
    else
        EHfd0i=repmat(EHfd0,[1 length(np_arg)]);
    end
else
    if isempty(Ie0)
        Ie0i=[];
    else
        Ie0p=permute(Ie0,[3 1 2]);
        % - move the interpolation dimension to 1st place
        % Iip=interp1(nx0,I0p,nx_arg);
        % I0 is (3 x Ms x N)
        % I0p is (N x 3 x Ms)
        % We managed to squeeze the call into a lambda form
        % Output of fwm_field is EHf (6 x Mi x N);
        % BESTGRID takes (N x 6 x Mi)
        Ie0i=permute(interp1(np0,Ie0p,np_arg),[2 3 1]);
    end
    if isempty(Im0)
        Im0i=[];
    else
        Im0p=permute(Im0,[3 1 2]);
        Im0i=permute(interp1(np0,Im0p,np_arg),[2 3 1]);
    end
    if isempty(EHfu0)
        EHfu0i=[];
    else
        % Move the interpolation dimension to 1st place
        EHfu0i=permute(interp1(np0,EHfu0.',np_arg),[2 3 1]);
    end
    if isempty(EHfd0)
        EHfd0i=[];
    else
        EHfd0i=permute(interp1(np0,EHfd0.',np_arg),[2 3 1]);
    end
end
EHf=fwm_field(zd,eground,perm,ksa,np_arg,0,Ie0i,Im0i,EHfu0i,EHfd0i,...
    kia,dzl,dzh);
% Move the grid argument (in this case, np) to the first position.
result=permute(EHf,[3 1 2]);
