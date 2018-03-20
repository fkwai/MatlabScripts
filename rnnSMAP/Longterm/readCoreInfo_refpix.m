function refpix = readCoreInfo_refpix( pID )

% refpix = readCoreInfo_refpix( 16020917)

pIDstr=sprintf('%08d',pID);
siteIDstr=pIDstr(1:4);

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];

%% read refpix file
fileRefpix=[folderSiteInfo,'refpix','_',pIDstr,'.txt'];

if exist(fileRefpix,'file')==2
    refpix=struct('id',[],'idstr',[],'staW',[],'layerD',[],'layerW',[]);
    fid=fopen(fileRefpix);
    tline='%';
    while strcmp(tline(1),'%')
        tline=fgets(fid);
    end
    nLayer=str2num(tline);
    tline=fgets(fid);
    tline=fgets(fid);
    C1=strsplit(tline,{',','\n'});
    layerW=cellfun(@str2num,C1(1:end-1));
    for i=1:nLayer
        refpix(i).layerW=layerW(i);
        tline=fgets(fid);
        C=strsplit(tline,{',','\n'});
        nSta=length(C)-2;
        refpix(i).id=cellfun(@str2num,C(2:end-1));
        
        tline=fgets(fid);
        C=strsplit(tline,{',','\n'});
        refpix(i).layerD=str2num(C{1});
        refpix(i).staW=cellfun(@str2num,C(2:nSta+1));
    end    
    fclose(fid);
else
    refpix=[];
end


end

