
%add calculated ret into HUCstr
load rET_new
load('HUCstr_HUC4_32.mat')
[ny,nx,nz]=size(rET);
nday=zeros(1,1,nz);
nday(1,1,:)=eomday(floor(t/100),t-floor(t/100)*100);
nday=repmat(nday,[ny,nx,1]);


mask_nldas=load('mask_huc4_nldas_32.mat');
mask_nldas=mask_nldas.mask;
nldasT=datenum(num2str(t),'yyyymm');

HUCstr = grid2HUC( 'rET',rET.*nday,nldasT,mask_nldas,HUCstr,HUCstr_t);
HUCstr = grid2HUC( 'rETs',rETs.*nday,nldasT,mask_nldas,HUCstr,HUCstr_t);
 
%difference between rET and PET
x=[];y=[];
for i=1:length(HUCstr)
    x=[x,mean(HUCstr(i).rET)];
    y=[y,mean(HUCstr(i).PEvp)];
end
plot(x,y,'*');
hold on
plot([50,300],[50,300],'k','linewidth',2)
hold off