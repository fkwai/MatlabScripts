function [ missfile ] = download_datacheck( product, year, localfolder, timereso)
%DOWNLOAD_DATACHECK Summary of this function goes here
%   Detailed explanation goes here
% localfolder='Y:\NLDAS\3H\NOAH';
% product = 'NOAH';
% year=1993:2013;
% timereso='H';%or ='M'

mw=ftp('hydro1.sci.gsfc.nasa.gov');
ftpdir=['/data/s4pa/NLDAS/NLDAS_',product,'0125_',timereso,'.002'];
missfile=[];
for y=year
    for d=yeardays(y)
        tfolder=[localfolder,'\',num2str(y),'\',num2str(d,'%03d')];
        if exist(tfolder)==7
            files=dir(fullfile(tfolder,'*.grb'));
            h=[];
            for i=1:length(files)
                filename=files(i).name;
                th=strsplit(filename,'.');
                th=str2num(th{3});
                h=[h;th];
            end
            hh=0:100:2300;
            missind=find(~ismember(hh,h));
            for j=1:length(missind)
                cd(mw,[ftpdir,'/',num2str(y),'/',num2str(d,'%03d')]);                
                mget(mw, ['*',num2str(hh(missind),'%04d'),'*'],tfolder);
                missfile=[missfile;y,d,hh(missind)];
            end                        
        else
            mkdir(tfolder);
            cd(mw,[ftpdir,'/',num2str(y),'/',num2str(d,'%03d')]);
            mget(mw, 'NLDAS*',tfolder);
        end        
    end
end




end

