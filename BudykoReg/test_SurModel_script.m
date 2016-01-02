
dataorg_GRDC;
dataorg_HUC;

par=[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI,SimInd];

ind=find(~isnan(E)&~isnan(Ep)&~isnan(P)&~isnan(Ampf)&prod(~isnan(par),2)&...
    E~=0&Ep~=0&P~=0&Ampf~=0);
E=E(ind);
Ep=Ep(ind);
P=P(ind);
Ampf=Ampf(ind);
par=par(ind,:);

f=@(X) turkPike2(X,[2,0]);
x=Ep./P;
y=E./P;
amp=Ampf./P;
dy=y-f(x);
doAridityRm=1;
doMeanDepRm=1;

if doAridityRm==1
    X=ones(length(x),2);
    X(:,2)=x;
    bArid=regress(dy,X);
    dArid=X*bArid;
    dy=dy-dArid;
else
    bArid=0;
end

if doMeanDepRm==1
    dymean=mean(dy);
    dy=dy-dymean;    
else
    dymean=0;
end

%old regression
[rp,cp]=size(par);
X=zeros(length(amp),2+cp);
X(:,1)=1;
X(:,2)=amp;
X(:,3:2+cp)=par;
Y=dy;
[df,R2,b]=regress_kuai(Y,X(:,2:end));
rmse = sqrt(sum((df-dy).^2)/length(dy));
b2=b;

%new regression
np=1+4*2+2;
options = optimset('MaxFunEvals', 3000*np,'MaxIter',3000*np);
p = fminsearch(@(p) additiveSurModel(p,dy,amp,par(:,[1:4]),par(:,[6,7])),ones(np,1),options);
[rmse,yn]=additiveSurModel(p,dy,amp,par(:,[1:4]),par(:,[6,7]));
R 
p2=p;


np=1+(size(par,2)-1)*2+1;
options = optimset('MaxFunEvals', 3000*np,'MaxIter',3000*np);
p = fminsearch(@(p) additiveSurModel(p,dy,amp,par(:,1:end-1),par(:,end)),ones(np,1),options);
[rmse,yn]=additiveSurModel(p,dy,amp,par(:,1:end-1),par(:,end));
SSE=sum((Y-yn).^2);
SSTO=(length(Y)-1)*var(Y);
R2=1-SSE/SSTO;
p2=p;

options = optimset('MaxFunEvals', 3000*(np+1),'MaxIter',3000*(np+1));
p = fminsearch(@(p) additiveSurModel(p,dy,amp,par(:,1:end),0),ones(np+1,1),options);
[rmse,yn]=additiveSurModel(p,dy,amp,par(:,1:end),0);
SSE=sum((Y-yn).^2);
SSTO=(length(Y)-1)*var(Y);
R2=1-SSE/SSTO;

options = optimset('MaxFunEvals', 3000*(np),'MaxIter',3000*(np));
p = fminsearch(@(p) additiveSurModel(p,dy,amp,par(:,[1:3,5:7]),par(:,4)),ones(np,1),options);
[rmse,yn]=additiveSurModel(p,dy,amp,par(:,[1:3,5:7]),par(:,4));
SSE=sum((Y-yn).^2);
SSTO=(length(Y)-1)*var(Y);
R2=1-SSE/SSTO;
