function [rET1, rET3,t,x,y] = rET_Calculate_GLDAS( GLDASfolder,DEMfile,sd,ed)
%calculate rET using GLDAS files. It is write for CLM
%product.
%input:
% GLDASfolder='Y:\GLDAS\V2\GLDAS_V2_mat';
% DEMfile='E:\work\DataAnaly\dem_GLDAS.mat';
% sd=200001;
% ed=201312;

sdn=datenum(num2str(sd),'yyyymm');
edn=datenum(num2str(ed),'yyyymm');
refT=sdn:edn;

%current daily data is saved by month.
ymstr=unique(str2num(datestr(refT,'yyyymm')));
rET_all_1=zeros(180,360,length(ymstr));
rET_all_3=zeros(180,360,length(ymstr));

for i=1:length(ymstr)
    GLDASfolder_ym=[GLDASfolder,'\',num2str(ymstr(i))];
    E_CLM_data=load([GLDASfolder_ym,'\','Evap.mat']);
    SWnet_CLM_data=load([GLDASfolder_ym,'\','SWnet.mat']);
    LWnet_CLM_data=load([GLDASfolder_ym,'\','LWnet.mat']);
    PSurf_CLM_data=load([GLDASfolder_ym,'\','PSurf.mat']);
    Qair_CLM_data=load([GLDASfolder_ym,'\','Qair.mat']);
    Tair_CLM_data=load([GLDASfolder_ym,'\','Tair.mat']);
    Wind_CLM_data=load([GLDASfolder_ym,'\','Wind.mat']);
    dem_data=load(DEMfile);
    
    % data to 3d grid
    x=E_CLM_data.crd(:,1);
    y=E_CLM_data.crd(:,2);
    t=E_CLM_data.t;
    SWnetgrid=data2grid3d(SWnet_CLM_data.SWnet,x,y,1);
    LWnetgrid=data2grid3d(LWnet_CLM_data.LWnet,x,y,1);
    PSurfgrid=data2grid3d(PSurf_CLM_data.PSurf,x,y,1);
    Qairgrid=data2grid3d(Qair_CLM_data.Qair,x,y,1);
    Tairgrid=data2grid3d(Tair_CLM_data.Tair,x,y,1);
    Windgrid=data2grid3d(Wind_CLM_data.Wind,x,y,1);
    
    %calculate rET
    dem=dem_data.dem_GLDAS;
    Rad=SWnetgrid.*0.0864 + LWnetgrid* 0.0864;
    % http://earthscience.stackexchange.com/questions/2360/how-do-i-convert-specific-humidity-to-relative-humidity
    Hmd=0.263.*Qairgrid.*PSurfgrid./exp((17.67.*Tairgrid)./(Tairgrid+243.51))/100;
    e0 = (exp((16.78.*Tairgrid-116.9)./(Tairgrid+237.3)));
    Wnd=Windgrid;
    T=Tairgrid;
    Elev=repmat(dem,[1,1,length(t)]);
    tau=0;
    ref=0;
    [rET1,rETs,Rn,Hb,Hli]=PenmanMonteith(Rad,Hmd,e0,Wnd,T,Elev,tau,ref,1);
    [rET3,rETs,Rn,Hb,Hli]=PenmanMonteith(Rad,Hmd,e0,Wnd,T,Elev,tau,ref,3);
    rET_all_1(1:150,:,i)=sum(rET1,3);
    rET_all_3(1:150,:,i)=sum(rET3,3);
    i
end

x=sort(unique(x));
y=sort(unique(y),'descend');
rET1=rET_all_1;
rET3=rET_all_3;
t=ymstr;

end

