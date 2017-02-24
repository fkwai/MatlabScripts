
%% fake dataset
nt=100;
nc=2;
t=[1:nt]';
x1=sin(0:nc*2*pi/(nt-1):nc*2*pi)';
x2=cos(0:nc*2*pi/(nt-1):nc*2*pi)';
y=3*x1+2*x2+rand(nt,1)*10;
plot(t,[x1,x2,y])

%options = optimoptions(@fmincon,'MaxIter',2,'MaxFunEvals',2);
options = optimoptions(@fmincon,'MaxIter',1);

%options = optimoptions(@fmincon);


%% ARIMA
p=3;
d=0;
q=3;
nInt=max(p,d+1);
yTrain=y;
xTrain=[x1,x2];

model = arima(p,d,q);  
model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Constant',0,'Display','off','Options',options);
tic
for k=1:1000
    k
    AR0=model.AR;
    Beta0=model.Beta;
    Constant0=model.Constant;
    MA0=model.MA;
    V0=model.Variance;    
    SAR0=model.SAR;
    SMA0=model.SMA;
    model = arima(p,d,q);      
    model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Options',options,'Display','off',...
        'AR0',AR0,'MA0',MA0,'SAR0',SAR0,'SMA0',SMA0,'Beta0',Beta0,'Constant0',Constant0,'V0',V0);    
end
toc
model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Constant',0);
yp = forecast(model,nt-nInt,'X0',xTrain(1:nInt,:),'XF',xTrain(nInt+1:end,:));

tic
model2 = arima(p,d,q);
model2 = estimate(model2,yTrain(nInt+1:end),'X',xTrain,'Constant',0);
toc
yp2 = forecast(model2,nt-nInt,'X0',xTrain(1:nInt,:),'XF',xTrain(nInt+1:end,:));

plot(t(nInt+1:end),[y(nInt+1:end),yp,yp2])


%% matlab example
% load Data_CreditDefaults
% X = Data(:,[1 3:4]);
% nt = size(X,1);
% y = Data(:,5);
% 
% p=1;
% d=1;
% q=1;
% nInt=max(p,d+1);
% y0 = y(1:nInt);
% y1 = y(nInt+1:end);
% x0 = X(1:nInt,:);
% x1 = X(nInt+1:end,:);
% Beta0 = [0.5 0.5 0.5];
% model = arima(p,d,q);
% estmodel = estimate(model,yEst,'Y0',y0,'X',X)
% yp = forecast(estmodel,nt-nInt,'X0',x0,'Y0',y0,'XF',x1);
% plot(1:nt-nInt,[y1,yp])


