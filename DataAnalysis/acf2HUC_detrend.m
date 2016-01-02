function  HUCstr  = acf2HUC_detrend( HUCstr,sd,ed)
%AMP2HUC Summary of this function goes here
%   add acf after detrend and hurst exp. Scale and data range is hard
%   coded.

sdn=datenum(num2str(sd),'yyyymmdd');
edn=datenum(num2str(ed),'yyyymmdd');
tm=unique(str2num(datestr(sdn:edn,'yyyymm')));


for i=1:length(HUCstr)
    t=HUCstr(i).GRACEt;
    s=HUCstr(i).GRACE;
    tmGRACE=str2num(datestr(t,'yyyymm'));
    [C,iGrace,iInput]=intersect(tmGRACE,tm);
    if length(iInput)~=length(tm)
        warning('sd ed not fit')
    end
    t=t(iGrace);
    s=s(iGrace);
    
    s=interpTS(s,t,'spline');
    if(~isempty(s))
        [sfit,RMS] = detrendMFDFA(s,[48,72],0);
        acf_dtr48=autocorr(sfit(:,1),1);
        pcf_dtr48=parcorr(sfit(:,1),12);
        acf_dtr72=autocorr(sfit(:,2),1);
        pcf_dtr72=parcorr(sfit(:,2),12);
        HUCstr(i).acf_dtr48=acf_dtr48(2);
        HUCstr(i).pcf_dtr48=pcf_dtr48;
        HUCstr(i).acf_dtr72=acf_dtr72(2);
        HUCstr(i).pcf_dtr72=pcf_dtr72;
        
        scalelog=[2,4,8,16,32,64,128]';
        [sfit,RMS] = detrendMFDFA(s,scalelog,0);
        C=polyfit(log2(scalelog),log2(RMS),1);
        HUCstr(i).HurstExp=C(1);
    else
        HUCstr(i).acf_dtr48=nan;
        HUCstr(i).pcf_dtr48=nan;
        HUCstr(i).acf_dtr72=nan;
        HUCstr(i).pcf_dtr72=nan;
        HUCstr(i).HurstExp=nan;
    end
end

end