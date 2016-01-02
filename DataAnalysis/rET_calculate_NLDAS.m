function [rET1, rET3, t] = rET_calculate_NLDAS(dem,mask,FORAfolder,NOAHfolder,sd,ed)
% Calculate rET from daily NLDAS data. 

% load('E:\Kuai\DataAnaly\global_dem\dem_NLDAS.mat');
% load('E:\Kuai\DataAnaly\mask_huc4_nldas_32.mat');
% FORAfolder='Y:\NLDAS\3H\FORA_daily_mat';
% NOAHfolder='Y:\NLDAS\3H\NOAH_daily_mat';
% sd=200001;
% ed=201312;

sdn=datenum(num2str(sd),'yyyymm');
edn=datenum(num2str(ed),'yyyymm');
refT=sdn:edn;

%current daily data is saved by month. 
ymstr=unique(str2num(datestr(refT,'yyyymm')));
rET_all_1=zeros(224,464,length(ymstr));
rET_all_3=zeros(224,464,length(ymstr));

for i=1:length(ymstr)    
    NOAHfolder_ym=[NOAHfolder,'\',num2str(ymstr(i))];
    FORAfolder_ym=[FORAfolder,'\',num2str(ymstr(i))];
    load([NOAHfolder_ym,'\NSWRS.mat']);
    load([NOAHfolder_ym,'\NLWRS.mat']);
    tNOAH=t;
    load([FORAfolder_ym,'\TMP.mat']);
    load([FORAfolder_ym,'\SPFH.mat']);
    load([FORAfolder_ym,'\PRES.mat']);
    load([FORAfolder_ym,'\UGRD.mat']);
    load([FORAfolder_ym,'\VGRD.mat']);
    load([FORAfolder_ym,'\PEVAP.mat']);
    tFORA=t;
    
    [C,iNOAH,iFORA]=intersect(tNOAH,tFORA);
    t=tFORA(iFORA);
    
    NSWRSgrid = data2grid3d( NSWRS(:,iNOAH),crd(:,1),crd(:,2),1/8 );
    NLWRSgrid = data2grid3d( NLWRS(:,iNOAH),crd(:,1),crd(:,2),1/8 );
    TMPgrid = data2grid3d( TMP(:,iFORA),crd(:,1),crd(:,2),1/8 );
    SPFHgrid = data2grid3d( SPFH(:,iFORA),crd(:,1),crd(:,2),1/8 );
    PRESgrid = data2grid3d( PRES(:,iFORA),crd(:,1),crd(:,2),1/8 );
    UGRDgrid = data2grid3d( UGRD(:,iFORA),crd(:,1),crd(:,2),1/8 );
    VGRDgrid = data2grid3d( VGRD(:,iFORA),crd(:,1),crd(:,2),1/8 );
    PEVAPgrid = data2grid3d( PEVAP(:,iFORA),crd(:,1),crd(:,2),1/8 );
    
    Rad=NSWRSgrid.*0.0864 + NLWRSgrid* 0.0864;
    % http://earthscience.stackexchange.com/questions/2360/how-do-i-convert-specific-humidity-to-relative-humidity
    Hmd=0.263.*SPFHgrid.*PRESgrid./exp((17.67.*TMPgrid)./(TMPgrid+243.51))/100;
    e0 = (exp((16.78.*TMPgrid-116.9)./(TMPgrid+237.3)));
    Wnd=sqrt(UGRDgrid.^2+VGRDgrid.^2);
    T=TMPgrid;
    Elev=repmat(dem,[1,1,length(iNOAH)]);
    tau=0;
    ref=0;    
   
    [rET1,rETs,Rn,Hb,Hli]=PenmanMonteith(Rad,Hmd,e0,Wnd,T,Elev,tau,ref,1);
    [rET3,rETs,Rn,Hb,Hli]=PenmanMonteith(Rad,Hmd,e0,Wnd,T,Elev,tau,ref,3);
    
    %convert to monthly and save
    rET_all_1(:,:,i)=sum(rET1,3);
    rET_all_3(:,:,i)=sum(rET3,3);
    i
end
rET1=rET_all_1;
rET3=rET_all_3;
t=ymstr;

end

