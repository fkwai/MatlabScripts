function [k,val2,pos] = insertZero(val,varargin)
k = []; val2=val; pos={};
if min(val)*max(val)>=0
    k = [];
    return
end
if ~isempty(varargin)
    pos = varargin{1};
end
for i=1:length(val)
    if val(i)<-1e-12 && val(i+1)>1e-12
        k  = i;
        val2 = [val(1:k) 0 val(k+1:end)];
        if ~isempty(pos)
            x = (-val(k))/(val(k+1)-val(k));
            pos2 = [pos(1:k) pos(k)+x *(pos(k+1)-pos(k)) pos(k+1:end)];
            pos = pos2;
        end
        return
    end
end
