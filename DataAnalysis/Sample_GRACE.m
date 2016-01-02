
%   1. load grace data. 
%   E:\Kuai\GRACE\grace_global.mat has grace data for global
GraceData=load('grace_global.mat');
x=GraceData.LOCATIONS(1,:);
y=GraceData.LOCATIONS(2,:);


%   2. Transfer data to time series for later analysis
GraceTS=data2ts(GraceData.DATA',GraceData.T);

%   3. Calculate amplitude of GRACE data
%   very time comsuming.. Recommend save after this. 
[Amp,AvgAmp,StdAmp]=ts2Amp( GraceTS, 20040101, 20141230 );
%   can load data directly
load Amp_GRACE_global.mat

%   4. Transfer 1D array data to grid. 
GraceGrid_AvgAmp = data2grid(AvgAmp,x,y,1);

%   5. Show map and time series in MATLAB 
showGrid( GraceGrid_AvgAmp ,x-360,y,GraceTS)

%   6. Write to ASCII file and input into ArcGIS
writeASCII_GRACE(GraceGrid_AvgAmp,x,y,'GRACE_AvgAmp_global' );