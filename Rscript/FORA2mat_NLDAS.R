
FORA2mat_NLDAS<-function(year,month){
  library("rgdal")
  library("sp")
  library("R.matlab")
#   source("LDAS2mat_func.R")
      
  AttrFile=paste("F:/wrgroup/NLDAS_Forcing/FORA/2014/attr.txt",sep="")
  GribtabFile=paste("F:/wrgroup/NLDAS_Forcing/gribtab_NLDAS_FORA_hourly.002.txt",
                    sep="")
  MatfileDir="Y:/NLDAS/3H/FORA_daily_mat"
  
  for (y in year){
    for(m in month){
      ym=paste(as.character(y),formatC(m,width=2,flag="0"),sep="")
      FLtxt=paste("F:/wrgroup/NLDAS_Forcing/FORA/FileList/",ym,"_filelist.txt",sep="")
      MatSaveFolder=paste(MatfileDir,"/",ym,sep="")
      readNLDAS_daily(FLtxt,AttrFile,GribtabFile,MatSaveFolder)
    }
  }
}
