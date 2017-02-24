function  HUCstr  = amp2HUC_fft( HUCstr,sd,ed,varargin)
%AMP2HUC Summary of this function goes here
%   Detailed explanation goes here
%   varargin{1}: ind of HUCstr that do calculation


% load('HUCstr_HUC4_16.mat');
% sd=20031001;
% ed=20121001;

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
    s=HUCstr(i).GRACE;
    tmGRACE=datenumMulti(t,3);
    [C,iGrace,iInput]=intersect(tmGRACE,tm);
    if length(iInput)~=length(tm)
        warning('sd ed not fit')
    end
    t=t(iGrace);
    s=s(iGrace);
    
    s=interpTS(s,t,'spline');
    if(~isempty(s))
        [maxAmp,f,scales,Amp,yI]=fftBandAmplitude(s,12,[2/3, 5/3]);
        HUCstr(i).Amp_fft=maxAmp;
        [maxAmp,f,scales,Amp]=fftBandAmplitude(s,12);
        HUCstr(i).Amp_fft_noband=maxAmp;
        [maxAmp,f,scales,Amp, yRecon]=fftBandAmplitude(s,12,[1/2 Inf]);
        HUCstr(i).yRecon=yRecon;
    else
        HUCstr(i).Amp_fft=nan;
        HUCstr(i).Amp_fft_noband=nan;
        HUCstr(i).yRecon=nan;
        
    end
end




end

