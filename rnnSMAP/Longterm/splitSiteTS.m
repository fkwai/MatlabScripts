function [ outSite,outLSTM,outSMAP ] = splitSiteTS(tsSite,tsLSTM,tsSMAP)

outLSTM=[];
outSite=[];
outSMAP=[];
tSiteValid=tsSite.t(~isnan(tsSite.v));
tLSTMValid=tsLSTM.t(~isnan(tsLSTM.v));

if ~isempty(tSiteValid) && ~isempty(tLSTMValid)
    
    t1=max(tSiteValid(1),tsLSTM.t(1));
    t2=max(tsSMAP.t(1));
    t3=min(tSiteValid(end),tsSMAP.t(end));
    
    if t1<t2&&t2<t3
        % site
        ind0=find(tsSite.t>=t1&tsSite.t<=t3);
        ind1=find(tsSite.t>=t1&tsSite.t<=t2);
        ind2=find(tsSite.t>=t2&tsSite.t<=t3);
        outSite.t=tsSite.t(ind0);
        outSite.t1=tsSite.t(ind1);
        outSite.t2=tsSite.t(ind2);
        outSite.v=tsSite.v(ind0);
        outSite.v1=tsSite.v(ind1);
        outSite.v2=tsSite.v(ind2);
        
        % LSTM
        ind0=find(tsLSTM.t>=t1&tsLSTM.t<=t3);
        ind1=find(tsLSTM.t>=t1&tsLSTM.t<=t2);
        ind2=find(tsLSTM.t>=t2&tsLSTM.t<=t3);
        outLSTM.t=tsLSTM.t(ind0);
        outLSTM.t1=tsLSTM.t(ind1);
        outLSTM.t2=tsLSTM.t(ind2);
        outLSTM.v=tsLSTM.v(ind0);
        outLSTM.v1=tsLSTM.v(ind1);
        outLSTM.v2=tsLSTM.v(ind2);
        
        % SMAP
        ind0=find(tsSMAP.t>=t1&tsSMAP.t<=t3);
        outSMAP.t=tsSMAP.t(ind0);
        outSMAP.v=tsSMAP.v(ind0);
    end
end


end

