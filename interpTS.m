function v = interpTS( v,t,method )
%INTERPTS Summary of this function goes here
%   interpolate NAN values in time series.

ind=find(~isnan(v));
indn=find(isnan(v));
if ~isempty(indn)
    if ~isempty(ind)
    v0=v(ind);
    t0=t(ind);
    tq=t(indn);
    vq = interp1(t0,v0,tq,method);
    v(indn)=vq;
    else
        v=[];
    end
end

end

