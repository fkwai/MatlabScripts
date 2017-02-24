load('E:\Chaopeng\AMHG\usgs.mat')
load('E:\Kuai\SSRS\data\ggIIstr_mB_4949_fixnan.mat')

for i=1:length(usgs)
    usgs(i).id=str2num(usgs(i).name);
end
usgsID=[usgs.id]';

sd=datenumMulti(20021001,1);
ed=datenumMulti(20140930,1);
indGRACE=find(ggIIstr(1).GRACEt<=ed&ggIIstr(1).GRACEt>=sd);
tUSGS=[sd:ed]';
tGRACE=ggIIstr(1).GRACEt(indGRACE);


GRACEtab=zeros(length(ggIIstr),length(tGRACE));
USGStab=zeros(length(ggIIstr),length(tUSGS));
area=zeros(length(ggIIstr),1);

errori=[];
for i=1:length(ggIIstr)
    id=ggIIstr(i).ID;
    indUSGS=find(usgsID==id);
    
    if isempty(indUSGS)
        errori=[errori,i];
    else
        v=usgs(indUSGS).v;
        t=usgs(indUSGS).t;
        v(v<0)=nan;
%         v=interpTS(v,t,'spline');
        [C,ind1,ind2]=intersect(tUSGS,t);
        if length(ind2)<length(tUSGS)
            errori=[errori,i];
        else
            vv=v(ind2);
            if length(find(isnan(vv)))>30
                errori=[errori,i];
            else
                USGStab(i,:)=vv;
                v=interpTS(vv,tUSGS,'spline');
                area(i)=ggIIstr(i).Area_sqm;
            end
        end
    end
    
    vg=ggIIstr(i).GRACE(indGRACE);
    vg=interpTS(vg,tGRACE,'spline');
    GRACEtab(i,:)=vg;
end

ID=[ggIIstr.ID]';
ID(errori)=[];
USGStab(errori,:)=[];
GRACEtab(errori,:)=[];
area(errori,:)=[];

% convert unit to mm
area_mat=repmat(area,[1,length(tUSGS)]);
USGStab=USGStab.*(0.3048^3*86400*1000)./area_mat;

perc=10;
[USGStab_norm,lb,ub]=normalize_perc(USGStab,perc);
[GRACEtab_norm,lb,ub]=normalize_perc(GRACEtab,perc);


folder='E:\Kuai\rnnGRACE\';
dlmwrite([folder,'tabGRACE.csv'], GRACEtab, 'precision',16)
dlmwrite([folder,'tabUSGS.csv'], USGStab, 'precision',16)
dlmwrite([folder,'tabGRACE_norm.csv'], GRACEtab_norm, 'precision',16)
dlmwrite([folder,'tabUSGS_norm.csv'], USGStab_norm, 'precision',16)
dlmwrite([folder,'tabID.csv'], ID, 'precision',16)
dlmwrite([folder,'timeGRACE.csv'], tGRACE, 'precision',16)
dlmwrite([folder,'timeUSGS.csv'], tUSGS, 'precision',16)

