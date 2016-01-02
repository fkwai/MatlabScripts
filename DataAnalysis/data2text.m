file='E:\work\DataAnaly\toDan\GRACE_CSR';
GRACEmat='E:\work\GRACE\grace_global_CSR.mat';
GRACE2text( GRACEmat,file )

file='E:\work\DataAnaly\toDan\GRACE_JPL';
GRACEmat='E:\work\GRACE\grace_global_JPL.mat';
GRACE2text( GRACEmat,file )

clear all
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SWE');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist1');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist2');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist3');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist4');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist5');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist6');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist7');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist8');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist9');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SoilMoist10');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\Canopint');
SoilM_CLM=SoilMoist1+SoilMoist2+SoilMoist3+SoilMoist4+SoilMoist5+...
    SoilMoist6+SoilMoist7+SoilMoist8+SoilMoist9+SoilMoist10;
SWE_CLM=SWE;
Canopint_CLM=Canopint;
WaterContent_CLM=SWE_CLM+Canopint_CLM+SoilM_CLM;
WaterT_CLM=WaterContent_CLM-repmat(mean(WaterContent_CLM,2),[1,length(t)]);
file='E:\work\DataAnaly\toDan\GLDAS_SoilM_CLM';
GLDAS2text( SoilM_CLM,crd, t,file );
file='E:\work\DataAnaly\toDan\GLDAS_SWE_CLM';
GLDAS2text( SWE_CLM,crd, t,file );
file='E:\work\DataAnaly\toDan\GLDAS_Canopint_CLM';
GLDAS2text( Canopint_CLM,crd, t,file );
file='E:\work\DataAnaly\toDan\GLDAS_WaterT_CLM';
GLDAS2text( WaterT_CLM,crd, t,file );

clear all
%others
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\SWnet');
load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\LWnet');
RadNet_CLM=SWnet+LWnet;
file='E:\work\DataAnaly\toDan\GLDAS_RadNet_CLM';
GLDAS2text( RadNet_CLM,crd, t,file );

load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\GLDAS_Rainf_CLM');
file='E:\work\DataAnaly\toDan\Rainf';
GLDAS2text( Rainf,crd, t,file );

load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS\CLM\GLDAS_Snowf_CLM');
file='E:\work\DataAnaly\toDan\Snowf';
GLDAS2text( Snowf,crd, t,file );


