function [ data ] = readNLDAS_Daily(productName,t,fieldind)
% create this function in order to do parfor
[dataTemp,lat,lon,tnum,fieldLst] = readNLDAS_Hourly(productName,t,fieldind);
data=nanmean(dataTemp,3);
