
GLDAS2mat_daily<-function(year,month){  
  library("rgdal")
  library("sp")
  library("R.matlab")
  #source("LDAS2mat_func.R")
  
  
  AttrFile=paste("Y:/GLDAS/attr_GLDAS_NOAH10_3H_020.txt",sep="")
  GribtabFile=paste("Y:/GLDAS/gribtab_GLDAS_V2.tab",sep="")
  MatfileDir="Y:/GLDAS/V2/GLDAS_V2_mat/"
  dir.create(file.path(MatfileDir), showWarnings = FALSE)
  
  
  for (y in year){
    for(m in month){
      ym=paste(as.character(y),formatC(m,width=2,flag="0"),sep="")
      FLtxt=paste("Y:/GLDAS/V2/GLDAS_NOAH10_3H_020/FileList/",ym,"_filelist.txt",sep="")
      MatSaveFolder=paste(MatfileDir,"/",ym,sep="")
      readNLDAS_daily(FLtxt,AttrFile,GribtabFile,MatSaveFolder)
    }
  }
}
