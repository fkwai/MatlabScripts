function SimIndex2Shp( HUCstrFile, HUCshpfile,outputshpfile)
% This function will compute seasonal similarity index and Rsquare during
% fitting, and then write them to HUC shapefile. 
% reference paper: Berghuijs, W., & Sivapalan, M. (2014). Patterns of similarity of seasonal water balances: A window into streamflow variability over a range of time scales


% example:
% HUCstrFile='HUCstr_HUC4_32.mat';
% outputshpfile='E:\work\DataAnaly\HUC\HUC4_SimIndex.shp';
% HUCshpfile='E:\work\DataAnaly\HUC\HUC4_main.shp';
% SimIndex( HUCstrFile, HUCshpfile,outputshpfile);

load(HUCstrFile)
shape=shaperead(HUCshpfile);

if(length(shape)~=length(HUCstr))
    error('input HUCstr and shapefile do not match')
end

fo = fitoptions('Method','NonlinearLeastSquares');
fp=fittype(@(a,s,M,t) M*(1+a*sin(2*pi*(t-s)/12)),...
    'problem','M','independent','t','dependent','z','options',fo);
ft=fittype(@(a,s,M,t) M+a*sin(2*pi*(t-s)/12),...
    'problem','M','independent','t','dependent','z','options',fo);
t=[1:length(HUCstr_t)]';

for i=1:length(HUCstr)
    P=HUCstr(i).Rain+HUCstr(i).Snow;
    T=HUCstr(i).TMP;    
    if isempty(find(isnan(P), 1))&&isempty(find(isnan(T), 1))
        [fpobj,fpgof,output]=fit(t,P,fp,'problem',mean(P));
        ap=fpobj.a;
        sp=fpobj.s;
        rsp=fpgof.rsquare;        
        [ftobj,ftgof,output]=fit(t,T,ft,'problem',mean(T));
        at=ftobj.a;
        st=ftobj.s;
        rst=ftgof.rsquare;        
        SimInd=ap*sign(at)*cos(2*pi*(sp-st)/12);
        shape(i).rsp=rsp;
        shape(i).rst=rst;
        shape(i).SimInd=SimInd;
    else
        shape(i).rsp=0;
        shape(i).rst=0;
        shape(i).SimInd=0;
    end    
end
shapewrite(shape,outputshpfile)
end

