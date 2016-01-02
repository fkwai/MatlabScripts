function [ outputfiles ] = CRUNCEP_daterange( files,daterange )
%CRUNCEP_DATERANGE Summary of this function goes here
%   input:
%   files: all nc data
%   daterange: example: daterange=[19900101,20000101];
%   output: files that inside daterange    
%   see CRUNCEP_weather_data.m

d1=num2str(daterange(1));
d2=num2str(daterange(2));
d1=str2num(d1(1:6));
d2=str2num(d2(1:6));

d=zeros(length(files),1);
for i=1:length(files)
    [pathstr,name,ext]=fileparts(files(i).name);
    y=str2num(name(end-6:end-3));
    m=str2num(name(end-1:end));
    d(i)=y*100+m;
end

ind=find(d>=d1&d<=d2);
outputfiles=files(ind);


end