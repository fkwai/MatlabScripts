% This code will show how to use funtions in repo to generate a HUCstr
% file.


% initial HUCstr
hucshapefile='HUC\HUC4_main';
IDfieldname='HUC4';
HUCstr = initialHUCstr( hucshapefile,IDfieldname );
load('common_datenum.mat');
HUCstr_t=t;
%save HUCstr_HUC4_32 HUCstr HUCstr_t
%load('HUCstr_HUC4_32.mat');

% grace
mask_grace=load('mask_huc4_grace_32.mat');
mask_grace=mask_grace.mask;
grace=load('graceGrid.mat');
%S
HUCstr = grid2HUC_month( 'S',grace.graceGrid.*10,grace.t,mask_grace,HUCstr,HUCstr_t);
% dS
dSgrid=grace.graceGrid(:,:,2:end)-grace.graceGrid(:,:,1:end-1);
dSt=grace.t(2:end);
HUCstr = grid2HUC( 'dS',dSgrid.*10,dSt,mask_grace,HUCstr,HUCstr_t);

% nldas
mask_nldas=load('mask_huc4_nldas_32.mat');
mask_nldas=mask_nldas.mask;
nldas=load('nldasGridF.mat');

nldasT=datenum(num2str(nldas.t),'yyyymm');
HUCstr = grid2HUC( 'Rain',nldas.ARAINgrid,nldasT,mask_nldas,HUCstr,HUCstr_t);
HUCstr = grid2HUC( 'Snow',nldas.ASNOWgrid,nldasT,mask_nldas,HUCstr,HUCstr_t);
HUCstr = grid2HUC( 'Evp',nldas.EVPgrid,nldasT,mask_nldas,HUCstr,HUCstr_t);
HUCstr = grid2HUC( 'PEvp',nldas.PEVPRgrid,nldasT,mask_nldas,HUCstr,HUCstr_t);
HUCstr = grid2HUC( 'SnowM',nldas.SNOMgrid,nldasT,mask_nldas,HUCstr,HUCstr_t);

% USGS
usgsQ=load('Runoff_huc4.mat');
[C,itusgs,ithuc]=intersect(usgsQ.t,str2num(datestr(HUCstr_t,'yyyymm')));
[C,idusgs,idhuc]=intersect(usgsQ.hucid,[HUCstr.HUCid]);
for i=1:length(HUCstr)
    id=idusgs(idhuc==i);    
    if(~isempty(id))
        Q=usgsQ.Q(:,id);Q=Q';
        HUCstr(i).Q(ithuc)=Q(itusgs);
    end
end

%Amplitude
sd=20031001;
ed=20121001;
HUCstr  = amp2HUC( HUCstr, HUCstr_t,sd, ed,1 ,1001);
HUCstr  = amp2HUC( HUCstr, HUCstr_t,sd, ed,0 ,1001);

save HUCstr_HUC4_32 HUCstr HUCstr_t