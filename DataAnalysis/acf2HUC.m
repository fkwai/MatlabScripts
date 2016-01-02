function  HUCstr  = acf2HUC( HUCstr, HUCstr_t,varargin)
%AMP2HUC Summary of this function goes here
%   Detailed explanation goes here

% load('HUCstr_HUC4_16.mat');
% sd=20031001;
% ed=20121001;

scale=[];
if length(varargin)>0
    scale=varargin{1};
end

for i=1:length(HUCstr)
    t=HUCstr(i).GRACEt;
    s=HUCstr(i).GRACE;
    %s=HUCstr(i).yRecon;
    s=interpTS(s,t,'spline');
    acf=autocorr(s,1);
    pcf=parcorr(s,12);
    HUCstr(i).acf=acf(2);
    HUCstr(i).pcf=pcf;
    
    %HUCstr(i).acf_yRecon=acf(2);
    %HUCstr(i).pcf_yRecon=pcf;
end

end