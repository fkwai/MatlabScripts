
load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')
usgsShp='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';
fieldObs='obsH';
shapeObs=shaperead(usgsShp);

for iD=1:1
    
%     outFolder=['E:\Kuai\chuckwalla\GMS\chuckwalla\output\simNewMount',num2str(iD),'\'];   
%     caseStr={'f3','f4','f5','f6','f7'};
    
    outFolder=['E:\Kuai\chuckwalla\GMS\chuckwalla\output\test'];
    caseStr={'f5','new'};
    
    for k=1:length(caseStr)
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
    save([outFolder,'\grid.mat'],'grid')
    load([outFolder,'\grid.mat'])
    
    %% head comp
    f=figure('Position',[1,1,1200,800]);
    
    for k=1:length(caseStr)
        hobs=[];
        hsim=[];
        for i=1:length(shapeObs)
            X=shapeObs(i).X;
            Y=shapeObs(i).Y;
            ind=round(([Y,X]-g.DM.origin)./g.DM.d+1);
            IY=ind(1);IX=ind(2);
            hobs=[hobs;shapeObs(i).(fieldObs)];
            hsim=[hsim;grid(k).H1(IY,IX)];
        end
        subplot(2,3,k)
        plot(hobs,hsim,'r*');hold on
        plot121Line
        xlabel('observation')
        ylabel('simulation')
        rmse=sqrt(mean((hobs-hsim).^2));
        title([caseStr{k},'; rmse = ', num2str(rmse)]);
        axis equal
        xlim([70,160]);
        ylim([70,160]);
    end
    
    suffix = '.eps';
    fname=[outFolder,'\headComp'];
    fixFigure([],[fname,suffix]);
    saveas(gcf, fname);
    close(f)
    
    %% detrended variation
    mask=readGrid('E:\Kuai\chuckwalla\GMS\chuckwalla\data\mount\mount_GMS_obs.tif');
    mask.z(mask.z==255)=nan;
    
    %% K1
    for k=1:length(caseStr)
        f=figure('Position',[100,100,1300,800]);
        range=highlightPoints([],[],grid(k).K1);
        st=detrendedVariation(g.DM.x,g.DM.y,grid(k).K1.*mask.z);
        title([caseStr{k},'; K1; ', 'std = ',num2str(st)]);
        suffix = '.eps';
        fname=[outFolder,'\K1_',caseStr{k}];
        fixFigure([],[fname,suffix]);
        Colorbar_reset(range)
        saveas(gcf, fname);
        close(f)
    end
    
    %% K2
    for k=1:length(caseStr)
        f=figure('Position',[100,100,1300,800]);
        range=highlightPoints([],[],grid(k).K2);        
        st=detrendedVariation(g.DM.x,g.DM.y,grid(k).K2.*mask.z);
        title([caseStr{k},'; K2; ', 'std = ',num2str(st)]);
        suffix = '.eps';
        fname=[outFolder,'\K2_',caseStr{k}];
        fixFigure([],[fname,suffix]);
        Colorbar_reset(range)
        saveas(gcf, fname);
        close(f)
    end
end


