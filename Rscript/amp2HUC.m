function  HUCstr  = amp2HUC( HUCstr, HUCstr_t,sd, ed,option,startMD )
%AMP2HUC Summary of this function goes here
%   Detailed explanation goes here

% load('HUCstr_HUC4_16.mat');
% sd=20031001;
% ed=20121001;

for i=1:length(HUCstr)
    ts=[];
    ts.t=HUCstr_t;        
    ts.v=HUCstr(i).S;
    ind=find(~isnan(ts.v));
    ts.t=ts.t(ind);
    ts.v=ts.v(ind);
    if(~isempty(ind))
        [Amp,AvgAmp,StdAmp]=ts2Amp( ts, sd, ed,option,startMD );    
        if(option==0)
            HUCstr(i).Amp0=Amp;
            HUCstr(i).AvgAmp0=AvgAmp;
            HUCstr(i).StdAmp0=StdAmp;        
        end
        if(option==1)
            HUCstr(i).Amp1=Amp;
            HUCstr(i).AvgAmp1=AvgAmp;
            HUCstr(i).StdAmp1=StdAmp;        
        end
    else
        if(option==0)
            HUCstr(i).Amp0=[];
            HUCstr(i).AvgAmp0=0;
            HUCstr(i).StdAmp0=0;        
        end
        if(option==1)
            HUCstr(i).Amp1=[];
            HUCstr(i).AvgAmp1=0;
            HUCstr(i).StdAmp1=0;        
        end
        warning(['###', num2str(i),' huc is all empty']);
    end
end




end

