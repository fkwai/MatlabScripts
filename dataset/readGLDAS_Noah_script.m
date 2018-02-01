
global kPath
gridFile=[kPath.SMAP,filesep,'gridGLDAS_025'];
load(gridFile);
ny=length(lat);
nx=length(lon);

%% read a temp file to initial
folder=[kPath.GLDAS,'GLDAS_NOAH025_3H.2.1',filesep,'2015',filesep,'001',filesep];
fileLst=dir([folder,'*.nc4']);
fileName=[folder,fileLst(1).name];
info=ncinfo(fileName);
varLst={};

for k=1:length(info.Variables)
    var=info.Variables(k).Name;
    if strcmp(var,'time') || strcmp(var,'time_bnds') || strcmp(var,'lon') || strcmp(var,'lat')
        % do nothing
    else
        varLst=[varLst;var];
    end
end
nVar=length(varLst);

%% read data
parpool(40)
yrLst=2000:2018;
for yr=yrLst
    disp(['working on year ',num2str(yr)])
    tic
    saveFolder=[kPath.GLDAS,filesep,'GLDAS_Noah_Daily_Mat',filesep,num2str(yr),filesep];
    if ~exist(saveFolder,'dir')
        mkdir(saveFolder)
    end
    sd=datenumMulti(yr*10000+101,1);
    ed=datenumMulti(yr*10000+1231,1);
    tnum=[sd:ed]';
    nt=length(tnum);
    for iV=1:nVar
        var=varLst{iV};
        out=zeros(ny,nx,nt)*nan;        
        parfor iT=1:nt
            t=tnum(iT);
            [dataD,tD] = readGLDAS_Noah(t,var,'doDaily',1);
            out(:,:,iT)=dataD;
        end
        if size(out,3)~=length(tnum)
            error('some empty day?')
        end
        eval([var,'=out;']);
        save([saveFolder,var,'.mat'],var,'tnum','lon','lat','-v7.3');
    end    
    toc
end