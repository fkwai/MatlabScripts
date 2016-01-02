
NOAH2mat_NLDAS<-function(year,month){  
  library("rgdal")
  library("sp")
  library("R.matlab")
  source("LDAS2mat_func.R")
  
  
  AttrFile=paste("Y:/NLDAS/attr_NOAH_Hourly.txt",sep="")
  GribtabFile=paste("Y:/NLDAS//gribtab_NLDAS_NOAH.002.tab",
                    sep="")
  MatfileDir="Y:/NLDAS/3H/NOAH_daily_mat"
  
  for (y in year){
    for(m in month){
      ym=paste(as.character(y),formatC(m,width=2,flag="0"),sep="")
      FLtxt=paste("Y:/NLDAS/3H/NOAH/FileList/",ym,"_filelist.txt",sep="")
      MatSaveFolder=paste(MatfileDir,"/",ym,sep="")
      readNLDAS_hourly(FLtxt,AttrFile,GribtabFile,MatSaveFolder)
    }
  }
}
