
GLDAS2mat<-function(yearstr){
  setwd("F:/wrgroup")
  
  library("rgdal")
  library("sp")
  library("R.matlab")
  source("LDAS2mat_func.R")
  
  
  evalstr=paste("year=c(",yearstr,")")
  eval(parse(text=evalstr))
  
  AttrFile=paste("F:/wrgroup/NLDAS_Forcing/FORA/2014/attr.txt",sep="")
  GribtabFile=paste("F:/wrgroup/NLDAS_Forcing/gribtab_NLDAS_FORA_hourly.002.txt",
                    sep="")
  MatfileDir="F:/wrgroup/matfile/NLDAS_3H/FORA"
  
  for (y in year){
    for(m in c(1:12)){
      ym=paste(as.character(year),formatC(m,width=2,flag="0"),sep="")
      FLtxt=paste("F:/wrgroup/NLDAS_Forcing/FORA/FileList/",ym,"_filelist.txt",sep="")
      MatSaveFolder=paste(MatfileDir,"/",ym,sep="")
      readNLDAS_hourly(FLtxt,AttrFile,GribtabFile,MatSaveFolder)
    }
  }
}
