function [Amp,AvgAmp,StdAmp]=ts2Amp( ts, sd, ed,option,startMD )
%   this function analyse ts of each grace cell and generate average and
%   standard error of amplitude. 

%   ts: time series of each grace cell
%   sd: start date, in formate yyyymmdd. ex: 20020101
%   ed: end date, in formate yyyymmdd. ex: 20141230

n=length(ts);
Amp=[];
AvgAmp=[];
StdAmp=[];
for i=1:length(ts)
    lnan=sum(isnan(ts(i).v(:)));
    if(lnan==0)
        [avg, amp]=timeSeriesAmplitudes(ts(i), 0, [sd ed],option,startMD);
        %stde=std(amp);
        AvgAmp=[AvgAmp,avg];
        %StdAmp=[StdAmp,stde];
        Amp=[Amp,amp];
    else
        AvgAmp=[AvgAmp,nan];
        %StdAmp=[StdAmp,nan];
        Amp=[Amp,{[]}];
    end
    
end

end

