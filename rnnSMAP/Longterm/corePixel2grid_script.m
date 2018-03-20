% after read core stations (readCoreSite_script.m), combine those
% stations to SMAP pixel according to given voroni matrix.

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirSave=[dirCoreSite,'siteMat',filesep];

%% pixels
pidLstSurf=[04013602,...
    09013602,09013610,...
    16013604,...
    16023603,...
    16033603,16033604,...
    16043603,16043604,...
    16063603,...
    16073603,...
    48013601,...
    ];
pidLstSurfSf=[09013601,...
    16013603,...
    16023602,...
    16033602,...
    16043602,...
    16063602,...
    16073602,...
    ];
pidLstRoot=[04010903,04010904,...
    09010902,...
    16010905,16010921,16010922,16010935,16010936,16010937,16010938,...
    16020902,16020907,16020917,...
    16030902,...
    16040904,16040905,16040935,16040936,...
    16060903,16060904,...
    16070904,16070905,...
    48010902,48010911,...
    ];
pidLstRootSf=[04010907,04010910,04010911,...
    09010906,...
    16010906,16010907,16010913,...
    16020905,16020906,16020912,...
    16030911,16030916,...
    16040901,16040906,16040911,...
    16060906,16060907,...
    16070909,16070910,16070911,...
    ];

shiftLst=csvread([dirSave,'shiftLst.csv']);
pidLstAll={pidLstSurf,pidLstSurfSf,pidLstRoot,pidLstRootSf};
saveNameLst={'sitePixel_surf_unshift','sitePixel_surf_shift','sitePixel_root_unshift','sitePixel_root_shift'};
plotNameLst={'plotPixel_surf_unshift','plotPixel_surf_shift','plotPixel_root_unshift','plotPixel_root_shift'};
doVorLst=[0,0,0,0];

%% read all sites
for kk=1:length(1:length(pidLstAll))
    sitePixel=[];
    msg=[];
    pidLst=pidLstAll{kk};
    figFolder=[dirSave,plotNameLst{kk},filesep];
    doVor=doVorLst(kk);    
    for k=1:length(pidLst)
        pid=pidLst(k);
        if ~ismember(pid,shiftLst(:,1))
            [temp,m]=corePixel2grid(pid,'figFolder',figFolder);
        else
            shiftPixel=shiftLst(shiftLst(:,1)==pid,2:end);
            [temp,m]=corePixel2grid(pid,'figFolder',figFolder,'shiftPixel',shiftPixel);
        end
        sitePixel=[sitePixel;temp];        
        if ~isempty(m)
            msg=[msg,newline,m];
        end
    end
    save([dirSave,saveNameLst{kk},'.mat'],'sitePixel','msg')
    fid=fopen([dirSave,saveNameLst{kk},'_msg.txt'],'wt');
    fprintf(fid,msg);
    fclose(fid);
end

%% check weight read from voronoi file and calculated.
%load('sitePixel_surf.mat')
for k=1:length(sitePixel)
    temp=sitePixel(k);
    disp(num2str(sitePixel(k).ID));
    disp([VectorDim(temp.wHor,1),VectorDim(temp.wHorCal,1)]);
end

%% merge shift and non-shift mat, and name them
idLst=[0401,0901,1601,1602,1603,1604,1606,1607,4801];
labelLst={{'Reynolds';'Creek'},'Carman',{'Walnut';'Gulch'},...
    {'Little';'Washita'},{'Fort';'Cobb'},{'Little';'River'},...
    {'St.';'Josephs'},{'South';'Fork'},'TxSON'};
nameLst={'Reynolds Creek','Carman','Walnut Gulch',...
    'Little Washita','Fort Cobb','Little River',...
    'St. Josephs','South Fork','TxSON'};




