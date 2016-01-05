function [ GlobalGrid ] = GlobalGridOrg( daterange )
% calculate global grid for given daterange

% daterange=[200301,201212];
out.tym=unique(datenumMulti(datenumMulti(daterange(1),1):datenumMulti(daterange(2),1),3));
out.t=datenumMulti(out.tym,1);

%% Init
E_JBF_dir='Y:\ET_JBF\AET_JBF_10deg';
GRACE_dir='Y:\GRACE\graceGrid_CSR.mat';
GLDAS_dir='Y:\GLDAS\Monthly\GLDAS_matfile\NOAH_V2';

strc=struct('grid',[],'lon',[],'lat',[]);
E_JBF=strc;
GRACE=strc;

%% JBF E
E_JBF_data=load(E_JBF_dir);
grid=zeros(180,360,length(out.t));
[C,ind1,ind2]=intersect(out.tym,E_JBF_data.tym);
grid(:,:,ind1)=E_JBF_data.E_JBF(:,:,ind2);
E_JBF.grid=grid;
E_JBF.lon=-179.5:179.5;
E_JBF.lat=89.5:-89.5;
out.E_JBF=E_JBF;

%% GRACE
GRACE_data=load(GRACE_dir);
grid=zeros(length(GRACE_data.y),length(GRACE_data.x),length(out.t))*nan;
tym=datenumMulti(GRACE_data.t,3);
[C,ind1,ind2]=intersect(out.tym,tym);
grid(:,:,ind1)=GRACE_data.graceGrid(:,:,ind2);
GRACE.grid=grid*10;
GRACE.lon=GRACE_data.x;
GRACE.lat=GRACE_data.y;

% Amp0 Amp1
GRACEstrc.grid=zeros(length(GRACE_data.y),length(GRACE_data.x))*nan;
GRACEstrc.lon=GRACE_data.x;
GRACEstrc.lat=GRACE_data.y;
Amp_fft=GRACEstrc;
Amp1=GRACEstrc;
acf_dtr48=GRACEstrc;
acf_dtr72=GRACEstrc;
for i=1:length(GRACE.lon)
    for j=1:length(GRACE.lat)
        indzero=find(GRACE.grid(j,i,:)==0);
        indnan=find(isnan(GRACE.grid(j,i,:)));
        if length(indzero)+length(indnan)<length(out.t)*0.5 % get rid of more that half of 0 or nan
            ts.v=reshape(GRACE.grid(j,i,:),[length(out.t),1]);
            ts.t=out.t;
            %interpolation
            ts.v=interpTS(ts.v,ts.t,'spline');
            GRACE.grid(j,i,:)=ts.v;
            %Amp0
            [maxAmp,f,scales,Amp,yI]=fftBandAmplitude(ts.v,12,[2/3, 5/3]);
            Amp_fft.grid(j,i)=maxAmp;
            %Amp1
            sd=datenumMulti(daterange(1),2);
            ed=datenumMulti(daterange(end),2);
            [Amp,AvgAmp,StdAmp]=ts2Amp(ts,sd,ed,1,1001);
            Amp1.grid(j,i)=AvgAmp;
            %acf48 and acf72
            [sfit,RMS] = detrendMFDFA(ts.v,[48,72],0);
            acf_dtr48_temp=autocorr(sfit(:,1),1);
            acf_dtr48.grid(j,i)=acf_dtr48_temp(2);
            acf_dtr72_temp=autocorr(sfit(:,2),1);
            acf_dtr72.grid(j,i)=acf_dtr72_temp(2);
        else
            GRACE.grid(j,i,:)=nan;  % all zero to nan
        end        
    end
end

out.GRACE=GRACE;
out.Amp_fft=Amp_fft;
out.Amp1=Amp1;
out.acf_dtr48=acf_dtr48;
out.acf_dtr72=acf_dtr72;

%% GLDAS
field={'Tair','Rainf','Snowf'};
for i=1:length(field)
    GLDAS_data=load([GLDAS_dir,'/',field{i},'.mat']);
    [GLDAS_grid,xx,yy] = data2grid3d( GLDAS_data.(field{i}),GLDAS_data.crd(:,1),GLDAS_data.crd(:,2),1);
    yy=[89.5:-1:-89.5]';
    grid=zeros(length(yy),length(xx),length(out.t))*nan;
    [C,ind1,ind2]=intersect(out.tym,GLDAS_data.t);
    grid(1:150,:,ind1)=GLDAS_grid(:,:,ind2);
    strname=[field{i},'_GLDAS'];
    out.(strname).grid=grid;
    out.(strname).lon=xx;
    out.(strname).lat=yy;
end

% Change unit
Y=floor(out.tym/100);M=out.tym-Y*100;
ndayZ_GLDAS=reshape(eomday(Y,M),1,1,length(out.tym));
ndayG_GLDAS=repmat(ndayZ_GLDAS,length(yy),length(xx));
out.Rainf_GLDAS.grid=out.Rainf_GLDAS.grid.*ndayG_GLDAS*60*60*24*12; %mm/s to mm/year
out.Snowf_GLDAS.grid=out.Snowf_GLDAS.grid.*ndayG_GLDAS*60*60*24*12; %mm/s to mm/year

out.Prcp_GLDAS.grid=out.Rainf_GLDAS.grid+out.Snowf_GLDAS.grid;
out.Prcp_GLDAS.lat=out.Rainf_GLDAS.lat;
out.Prcp_GLDAS.lon=out.Rainf_GLDAS.lon;

%% SimIndex
out.SimIndex.grid=zeros(length(out.Prcp_GLDAS.lat),length(out.Prcp_GLDAS.lon))*nan;
out.SimIndex.lon=xx;
out.SimIndex.lat=yy;
for i=1:length(out.Prcp_GLDAS.lon)
    for j=1:length(out.Prcp_GLDAS.lat)
        P=reshape(out.Prcp_GLDAS.grid(j,i,:),[length(out.t),1]);
        T=reshape(out.Tair_GLDAS.grid(j,i,:),[length(out.t),1]);
        indzero=find(T==0);
        indnan=find(isnan(T));
        if length(indzero)+length(indnan)<length(out.t)*0.5 % get rid of more that half of 0 or nan 
            [ rsp, rst, SimInd ] = SimIndex( P, T, 12);
            out.SimIndex.grid(j,i)=SimInd;            
        end            
    end
end


%%
GlobalGrid=out;
save Y:\DataAnaly\GlobalGrid GlobalGrid

end

