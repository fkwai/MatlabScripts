% read NLDAS hourly data, convert to daily SMAP grid and save as matfile
% default to convert all fields. see the -1 line 27

global kPath
yLst=2015:2016;
dataLst={'FORA','FORB','NOAH'};

for yr=yLst
    sdn=datenumMulti(yr*10000+101,1);
    edn=datenumMulti(yr*10000+1231,1);
    tLst=sdn:edn;    
    for iData=1:length(dataLst)
        dataName=dataLst{iData};
        saveFolder=[kPath.NLDAS,'NLDAS_Daily',kPath.s,dataName,kPath.s,num2str(yr),kPath.s];
        mkdir(saveFolder)
        
        for iT=1:length(tLst)
            tic
            t=tLst(iT);
            % read NLDAS
            [dataTemp,lat,lon,tnumTemp,field] = readNLDAS_Hourly(dataName,t,-1);
            disp([dataName,' ',datestr(t)])
            
            % init dataNLDAS
            if iT==1
                ny=length(lat);
                nx=length(lon);
                dataNLDAS=zeros(ny,nx,length(sdn:edn),length(field))*nan;
            end
            
            % average to daily
            dataDaily=nanmean(dataTemp,3);
            toc
            
        end
        
        % write output
        for k=1:length(field)
            data=dataDaily(:,:,:,k);
            tnum=tLst;
            fieldName=field{k};
            save([saveFolder,fieldName,'.mat'],'data','tnum','lat','lon','-v7.3')
        end
    end
end