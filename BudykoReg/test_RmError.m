function test_RmError
%TEST_RMERROR Summary of this function goes here
%   Detailed explanation goes here
%clear all
clc

load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
load('Y:\DataAnaly\BasinStr\GRDCstr_new.mat')
global doPlot doMeanDepRm doAridityRm  %index of AoP term
global doErrRm docpAoP0 doErrRm_order doErrRm_minbound

doPlot=0;
doMeanDepRm=0;
doAridityRm=0;
Fields = {'AoP','SimInd','Amp1','SoP','NDVI','acf_dtr48'};

HUCstr0=HUCstr;
Mississippi_exclude
HUCstr1=HUCstr;

%% global grid
load('Y:\DataAnaly\GlobalGrid')
load('Y:\GRACE\GRACE_ERR_grid.mat')
GRDCstr_t2=GRDCstr_t(1:48);
[C,ind,ind2]=intersect(GlobalGrid.t,GRDCstr_t2);

[ny,nx,nz]=size(GlobalGrid.Rainf_GLDAS.grid);
P=reshape(mean(GlobalGrid.Prcp_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
Ep=reshape(mean(GlobalGrid.rET_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
E=reshape(mean(GlobalGrid.Evap_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
Snow=reshape(mean(GlobalGrid.Snowf_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
DAT=zeros(ny*nx,6)*nan;
DAT(:,1)=reshape(GlobalGrid.Amp_fft.grid,[ny*nx,1])./P;
DAT(:,2)=reshape(GlobalGrid.SimIndex.grid,[ny*nx,1]);
DAT(:,3)=reshape(GlobalGrid.Amp1.grid,[ny*nx,1]);
DAT(:,4)=Snow./P;
DAT(:,5)=reshape(GlobalGrid.NDVI.grid,[ny*nx,1]);
DAT(:,6)=reshape(GlobalGrid.acf_dtr48.grid,[ny*nx,1]);
GRACEerr(:,1)=reshape(leakage_Err,[ny*nx,1]);
GRACEerr(:,2)=reshape(measure_Err,[ny*nx,1]);
GRACEerr(GRACEerr>1000)=nan;

EJBF=mean(GlobalGrid.E_JBF.grid(:,:,1:48),3);
EGLDAS=mean(GlobalGrid.Evap_GLDAS.grid(:,:,1:48),3);
EJBF1d=reshape(EJBF,[ny*nx,1]);
EGLDAS1d=reshape(EGLDAS,[ny*nx,1]);

[xx,yy]=meshgrid(GlobalGrid.GRACE.lon,GlobalGrid.GRACE.lat);
AoP1d=DAT(:,1);
DAT2=DAT;

%% Start test
str=[];
for i1=2 %par
    if i1==1
        findex=1;
        ff=Fields(findex);
        str1=[str,'field=1; '];
    elseif i1==2
        findex=[1,3,6];
        ff=Fields(findex);
        str1=[str,'field=1,3,6; '];
    end
    
    for i2=0 % ex mississippi
        if i2==1
            HUCstr=HUCstr0;
            str2=[str1,'not ex MSP; '];
        elseif i2==2
            HUCstr=HUCstr1;
            str2=[str1,'ex MSP; '];
        elseif i2==0
            str2=str1;
        end
        
        for doErrRm=0  %error rm
            if ~doErrRm
                for th=[0,0.5,0.8,1,1.5,2,4]
                    str3=[str2,'not Scl Down; ','intp=',num2str(th)];
                    disp(str3);
                    AoP1d_intp=intpAoP(xx,yy,AoP1d,GRACEerr,th);
                    %runReg(HUCstr,HUCstr_t,GRDCstr,GRDCstr_t,ff);
                    DAT2(:,1)=AoP1d_intp;
                    runRegGlobal(GRDCstr,GRDCstr_t,ff,findex,E,Ep,P,DAT2,GRACEerr,EJBF1d,EGLDAS1d);
                    disp(' ')
                end
            else        %do ErrRm
                str3=[str2,'Scl Down; '];
                for doErrRm_order=[0.5,1,2]  % error rm order
                    for doErrRm_minbound=[0.5,1,2,3,4] % error rm min bound
                        for th=[0,1,2,3,4]
                            str4=[str3,'order=',num2str(doErrRm_order),'; ',...
                                'minbound=',num2str(doErrRm_minbound),'; '...
                                'intp=',num2str(th)];
                            disp(str4);
                            %runReg(HUCstr,HUCstr_t,GRDCstr,GRDCstr_t,ff)
                            AoP1d_intp=intpAoP(xx,yy,AoP1d,GRACEerr,th);
                            DAT2(:,1)=AoP1d_intp;
                            runRegGlobal(GRDCstr,GRDCstr_t,ff,findex,E,Ep,P,DAT2,GRACEerr,EJBF1d,EGLDAS1d);
                            disp(' ')
                        end
                    end
                end
            end
        end
    end
end

end

function runReg(HUCstr,HUCstr_t,GRDCstr,GRDCstr_t,ff)
global docpAoP0 doErrRm
ndig=2;


docpAoP0=0;
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( HUCstr,HUCstr_t,ff);
disp(['HUC4 solo:',num2str(R2,ndig)]);

docpAoP0=0;
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff);
disp(['GRDC solo:',num2str(R2,ndig)]);

%% transfer from HUC4 to GRDC
docpAoP0=0;
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( HUCstr,HUCstr_t,ff,GRDCstr_t);
Ra=R2;
if doErrRm
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
        budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff,HUCstr_t,b);
    Rb=R2;
    docpAoP0=0;
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
        budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff,HUCstr_t,b);
    Rc=R2;
    disp(['HUC4 to GRDC:',num2str(Ra,ndig),'; ',...
        num2str(Rb,ndig),'(not recal AoP0),',num2str(Rc,ndig),'(recal AoP0)']);
else
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
        budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff,HUCstr_t,b);
    disp(['HUC4 to GRDC:',num2str(Ra,ndig),',',num2str(R2,ndig)]);
end

%% transfer from GRDC to HUC4
docpAoP0=0;
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff,HUCstr_t);
Ra=R2;
if doErrRm
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
        budykoReg_MS_SCP( HUCstr,HUCstr_t,ff,GRDCstr_t,b);
    Rb=R2;
    docpAoP0=0;
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
        budykoReg_MS_SCP( HUCstr,HUCstr_t,ff,GRDCstr_t,b);
    Rc=R2;
    disp(['GRDC to HUC4:',num2str(Ra,ndig),'; ',...
        num2str(Rb,ndig),'(not recal AoP0),',num2str(Rc,ndig),'(recal AoP0)']);
else
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
        budykoReg_MS_SCP( HUCstr,HUCstr_t,ff,GRDCstr_t,b);
    disp(['GRDC to HUC4:',num2str(Ra,ndig),',',num2str(R2,ndig)]);
end

end

function runRegGlobal(GRDCstr,GRDCstr_t,ff,findex,E,Ep,P,DAT,GRACEerr,EJBF1d,EGLDAS1d)
global docpAoP0 docpErrMean
docpAoP0=0;
docpErrMean=0;

GRDCstr_t2=GRDCstr_t(1:48);
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]= ...
    budykoReg_MS_SCP(GRDCstr,GRDCstr_t,ff,GRDCstr_t2);
AoP0temp=docpAoP0;
ErrMeantemp=docpErrMean;

[Enew,Ebudyko,R2,b,D,bArid,dymean,ind,table]=budykoReg_SCP( E,Ep,P,DAT(:,findex),b,[2,0],0,GRACEerr);
rmse1=sqrt(nanmean((Enew-EJBF1d).^2));
rmse2=sqrt(nanmean((Enew-EGLDAS1d).^2));
disp(['Global map (cp Aop and ErrMean):',num2str(rmse1),'(JBF),',num2str(rmse2),'(GLDAS)']);

% docpAoP0=0;
% docpErrMean=ErrMeantemp;
% [Enew,Ebudyko,R2,b,D,bArid,dymean,ind,table]=budykoReg_SCP( E,Ep,P,DAT(:,findex),b,[2,0],0,GRACEerr);
% rmse1=sqrt(nanmean((Enew-EJBF1d).^2));
% rmse2=sqrt(nanmean((Enew-EGLDAS1d).^2));
% disp(['Global map (not cp Aop, cp ErrMean):',num2str(rmse1),'(JBF),',num2str(rmse2),'(GLDAS)']);

docpAoP0=AoP0temp;
docpErrMean=0;
[Enew,Ebudyko,R2,b,D,bArid,dymean,ind,table]=budykoReg_SCP( E,Ep,P,DAT(:,findex),b,[2,0],0,GRACEerr);
rmse1=sqrt(nanmean((Enew-EJBF1d).^2));
rmse2=sqrt(nanmean((Enew-EGLDAS1d).^2));
disp(['Global map (cp Aop, not cp ErrMean):',num2str(rmse1),'(JBF),',num2str(rmse2),'(GLDAS)']);

% docpAoP0=0;
% docpErrMean=0;
% [Enew,Ebudyko,R2,b,D,bArid,dymean,ind,table]=budykoReg_SCP( E,Ep,P,DAT(:,findex),b,[2,0],0,GRACEerr);
% rmse1=sqrt(nanmean((Enew-EJBF1d).^2));
% rmse2=sqrt(nanmean((Enew-EGLDAS1d).^2));
% disp(['Global map (not cp Aop and ErrMean):',num2str(rmse1),'(JBF),',num2str(rmse2),'(GLDAS)']);

end

function AoP1d_intp=intpAoP(xx,yy,AoP1d,GRACEerr,th)
ny=180;
nx=360;

if th~=0
    x1d=reshape(xx,[ny*nx,1]);
    y1d=reshape(yy,[ny*nx,1]);
    
    err=sqrt(sum(GRACEerr.^2,2));
    err1d=err/nanmean(err);
    
    bNan=isnan(AoP1d)|isinf(AoP1d);
    bTh=err1d>th;
    xq=x1d;xq(bNan)=[];
    yq=y1d;yq(bNan)=[];
    x=x1d;x(bNan|bTh)=[];
    y=y1d;y(bNan|bTh)=[];
    v=AoP1d;v(bNan|bTh)=[];
    
    vq=griddata(x,y,v,xq,yq,'natural');
    AoP1d_intp=AoP1d;
    AoP1d_intp(~bNan)=vq;
    
    %imagesc(reshape(AoP1d_intp,[ny,nx]),[0,0.5])

else
    AoP1d_intp=AoP1d;
end

end

