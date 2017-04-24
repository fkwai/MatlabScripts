load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')
usgsShp='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';

outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\simNew6\';

caseStr={'f5','f10','f15'};

for k=1:3
    shape=shaperead([outFolder,'\grid_',caseStr{k},'.shp']);
    if isfield(shape,'HKPARAMET')
        Km=rot90(reshape([shape.HKPARAMET],[190,115,2]));
    else
        Km=rot90(reshape([shape.HK],[190,115,2]));
    end
    Hm=rot90(reshape([shape.HEAD],[190,115,2]));
    
    grid(k).K1=Km(:,:,1);
    grid(k).K2=Km(:,:,2);
    grid(k).H1=Hm(:,:,1);
    grid(k).H2=Hm(:,:,2);    
end

%% plot map
shpObs='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';
fieldObs='obsH';
shape=shaperead(shpObs);

%% head comp
f=figure('Position',[1,1,600,1000]);

for k=1:3
    hobs=[];
    hsim=[];
    for i=1:length(shape)
        X=shape(i).X;
        Y=shape(i).Y;
        ind=round(([Y,X]-g.DM.origin)./g.DM.d+1);
        IY=ind(1);IX=ind(2);
        hobs=[hobs;shape(i).(fieldObs)];
        hsim=[hsim;grid(k).H1(IY,IX)];
    end
    subplot(3,1,k)
    plot(hobs,hsim,'r*');hold on
    plot121Line
    xlabel('observation')
    ylabel('simulation')
    rmse=sqrt(mean((hobs-hsim).^2));
    title([caseStr{k},'; rmse = ', num2str(rmse)]);
    axis equal
    xlim([70,150]);
    ylim([70,150]);
end

suffix = '.eps';
fname=[outFolder,'\headComp'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
close(f)

%% K1
for k=1:3
    f=figure('Position',[100,100,1300,800]);
    range=highlightPoints([],[],grid(k).K1);
    title([caseStr{k},'; K1']);
    suffix = '.eps';
    fname=[outFolder,'\K1_',caseStr{k}];
    fixFigure([],[fname,suffix]);
    Colorbar_reset(range)
    saveas(gcf, fname);
    close(f)
end

%% K2
for k=1:3
    f=figure('Position',[100,100,1300,800]);
    range=highlightPoints([],[],grid(k).K2);
    title([caseStr{k},'; K2']);
    suffix = '.eps';
    fname=[outFolder,'\K2_',caseStr{k}];
    fixFigure([],[fname,suffix]);
    Colorbar_reset(range)
    saveas(gcf, fname);
    close(f)
end