function  HUCstr  = amp2HUC( HUCstr,sd,ed,option,startMD,varargin )
%AMP2HUC Summary of this function goes here
%   Detailed explanation goes here
%   varargin{1}: ind of HUCstr that do calculation

% load('HUCstr_HUC4_16.mat');
% sd=20031001;
% ed=20121001;
% startMD=1001;
% option = 1 or 0

if ~isempty(varargin)
    iter=VectorDim(varargin{1},2);   % ind that do calculation
else
    iter=1:length(HUCstr);
end

sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tm=unique(datenumMulti(sdn:edn,3));

for i=iter
    t=HUCstr(i).GRACEt;
    v=HUCstr(i).GRACE;
    tmGRACE=datenumMulti(t,3);
    [C,iGrace,iInput]=intersect(tmGRACE,tm);
    ts=[];
    ts.t=datenumMulti(t(iGrace),1);
    ts.v=v(iGrace);
    ts.v=interpTS(ts.v,ts.t,'spline');
        
    if(~isempty(ts.v))
        [Amp,AvgAmp,StdAmp]=ts2Amp( ts, sd, ed,option,startMD );
         if(option==0)
%             HUCstr(i).Amp0=Amp;
%             HUCstr(i).AvgAmp0=AvgAmp;
%             HUCstr(i).StdAmp0=StdAmp;
            HUCstr(i).Amp0=AvgAmp;
        end
        if(option==1)
%             HUCstr(i).Amp1=Amp;
%             HUCstr(i).AvgAmp1=AvgAmp;
%             HUCstr(i).StdAmp1=StdAmp;
            HUCstr(i).Amp1=AvgAmp;
        end
    else
        if(option==0)
             HUCstr(i).Amp0=nan;
%             HUCstr(i).AvgAmp0=0;
%             HUCstr(i).StdAmp0=0;
        end
        if(option==1)
            HUCstr(i).Amp1=nan;
%             HUCstr(i).AvgAmp1=0;
%             HUCstr(i).StdAmp1=0;
        end
        warning(['###', num2str(i),' huc is all empty']);
    end
end




end

