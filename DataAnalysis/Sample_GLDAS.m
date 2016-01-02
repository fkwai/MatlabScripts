
%   1. load Rain fall product. 
%   I forgot to process the time string.. So do it here
load('Rainf.mat') 
t=datenum(num2str(t*100+1),'yyyymmdd');
x=crd(:,1);
y=crd(:,2);


%   2. Transfer data to time series for later analysis
Rainf_TS=data2ts(Rainf,t);

%   3. transfer 1d array data to grid
%   example: average rain fall
RainfAvg = mean(Rainf')';
RainfAvg_grid = data2grid( RainfAvg,x,y,1);

%   4. Show map and time series
showGrid( RainfAvg_grid ,x,y,Rainf_TS)

%   5. Write to ASCII file and input into ArcGIS
writeASCII_NLDAS(RainfAvg_grid,x,y,'RainfAvg_global.txt',1 );

