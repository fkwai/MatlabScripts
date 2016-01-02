function [ data,t,x,y,factor ] = readGRACE(  folder, dataset )
%READGRACE Summary of this function goes here
%   read GRACE data;
% updated version of grace_read. This one is faster and removed possible
% issue. 

current_folder = cd;
cd(folder);
files = dir(['GRCTellus.',dataset,'*.txt']);

%read factor
factorfile='CLM4.SCALE_FACTOR.DS.G300KM.RL05.txt';
fid = fopen(factorfile);
txt = textscan(fid,' %f %f %f','HeaderLines',14);
lon=txt{1};
lat=txt{2};
factor=txt{3};
fclose(fid);
x=lon;y=lat;

data=zeros(length(factor),length(files));
t=zeros(length(files),1);

for i = 1 : length(files)
    i
    dot=strfind(files(i).name,'.');
    %old format
    %sdate=files(i).name(dot(length(dot))+1:dot(length(dot))+8);    
    sdate=files(i).name(dot(2)+1:dot(2)+8);
    t(i)=datenum2(str2num(sdate));
    fid = fopen(files(i).name);
    txt = textscan(fid,' %f %f %f','HeaderLines',22);
    lon=txt{1};
    lat=txt{2};
    value=txt{3};
    fclose(fid);
    
    if find(lon-x~=0) &find(lat-y~=0)
        error(files(i).name);  %if any should fix this. 
    else
        data(:,i)=value.*factor;
    end
    
end
cd(current_folder);

end

