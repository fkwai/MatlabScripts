load('budykoData_global_v2.mat')

parTP=[2,0];b=[0.10566;-1.4752];
%parTP=[2,0.3];b=[0.2701;-2.0556];

mask2=ones(180,360);
E_GLDAS_1d=reshape(E_GLDAS.*mask2,180*360,1);
Ep_GLDAS_1d=reshape(Ep_GLDAS.*mask2,180*360,1);
P_GLDAS_1d=reshape(P_GLDAS.*mask2,180*360,1);
E_JBF_1d=reshape(E_JBF.*mask2,180*360,1);
Amp=reshape(Amp_fft.*mask2,180*360,1);

[E_CBE_1d,E_Budyko_1d,D]=budykoReg_B(E_JBF_1d,Ep_GLDAS_1d,P_GLDAS_1d,Amp,b,parTP,0 );
E_CBE=reshape(E_CBE_1d,180,360);
E_Budyko=reshape(E_Budyko_1d,180,360);
grid=E_JBF-E_CBE;

f=figure
xx=-179.5:179.5;
yy=89.5:-1:-89.5;
range=displayIndices(grid,[],xx,yy,1,0);
h = colorbar;
YTick=get(h,'YTick');
p = linearIntp(YTick,[0,1],range);
for i=1:length(p), labels{i}=num2str(p(i),4); end
set(h,'YTickLabel',labels)
axis equal tight
title('E JBF-E CBE')

showTS=1;
while(showTS)
    %show ts
    figure(f)
    [px,py]=ginput(1);
    %[px,py] = getpts(ax);
    cx=floor(px)+(xx(2)-xx(1))/2;
    cy=floor(py)+(yy(2)-yy(1))/2;
    ix=find(xx==cx);
    iy=find(yy==cy);
    disp([cx,cy]);
    disp(['Amp_fft = ',num2str(Amp_fft(iy,ix))]);
    disp(['Ep_GLDAS = ',num2str(Ep_GLDAS(iy,ix))]);
    disp(['P_GLDAS = ',num2str(P_GLDAS(iy,ix))]);
    disp(['E_JBF = ',num2str(E_JBF(iy,ix))]);
    disp(['E_GLDAS = ',num2str(E_GLDAS(iy,ix))]);
    disp(['Amp/P = ',num2str(Amp_fft(iy,ix)/P_GLDAS(iy,ix))]);
    disp(['E_Budyko = ',num2str(E_Budyko(iy,ix))]);
    disp(['E_CBE = ',num2str(E_CBE(iy,ix))]);
    disp(['Acf_dtr48 = ',num2str(Acf_dtr48(iy,ix))]);
    disp(['Pcf2_dtr48 = ',num2str(Pcf2_dtr48(iy,ix))]);
    disp(['Pcf3_dtr48 = ',num2str(Pcf3_dtr48(iy,ix))]);
    disp(' ');
    disp(' ');
    
    figure
    subplot(2,1,1)
    n=length(t);
    tt=datenum(num2str(t),'yyyymm');
    ts1.t=reshape(tt,n,1);ts1.v=reshape(Ep_GLDAS_grid(iy,ix,:),n,1);
    ts2.t=reshape(tt,n,1);ts2.v=reshape(P_GLDAS_grid(iy,ix,:),n,1);
    ts3.t=reshape(tt,n,1);ts3.v=reshape(E_JBF_grid(iy,ix,:),n,1);
    plotTS(ts1,'-ro');hold on
    plotTS(ts2,'-b*');hold on
    plotTS(ts3,'-k+');hold on
    title(['long=',num2str(cx),'; lat=',num2str(cy),'; ']);
    legend('Ep GLDAS','P GLDAS','E JBF')
    hold off
    
    subplot(2,1,2)
    n=length(tGRACE_comp);
    tt=datenum(num2str(tGRACE_comp),'yyyymm');
    ts.t=reshape(tt,n,1);ts.v=reshape(GRACE_grid(iy,ix,:),n,1);
    plotTS(ts,'-k*');hold on
    title(['long=',num2str(cx),'; lat=',num2str(cy),'; ']);
    legend('GRACE')
    hold off
end