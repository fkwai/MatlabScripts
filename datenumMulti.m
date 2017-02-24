function tout = datenumMulti( t,opt )
% Automaticlly find out format of input datenum and transfer as define
% only support datenum, yyyymmdd, yyyymm.

% opt 1: return datenum
% opt 2: return yyyymmdd
% opt 3: return yyyymm

% just for normal case (about year 1500 - 2700)

t=VectorDim(t,1);

if t(1)>10000000 %yyyymmdd
    if opt==1
        tout=datenum(num2str(t),'yyyymmdd');
    elseif opt==2
        tout=t;
    elseif opt==3
        tout=floor(t/100);
    end
elseif t>500000 %datenum
    if opt==1
        tout=t;
    elseif opt==2
        tout=str2num(datestr(t,'yyyymmdd'));
    elseif opt==3
        tout=str2num(datestr(t,'yyyymm'));
    end
else %yyyymm
    if opt==1
        tout=datenum(num2str(t),'yyyymm');        
    elseif opt==2
        tout=t*100+1;
    elseif opt==3
        tout=t;
    end
end

end

