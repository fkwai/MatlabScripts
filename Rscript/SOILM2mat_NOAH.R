library("rgdal")
library("sp")
library("R.matlab")

ProductName="NOAH"
year=c(2002:2014)
dir=paste("E:/work/LDAS/NLDAS_data/month/",ProductName,"/",sep="")
GribtabFile=paste("E:/work/LDAS/NLDAS_data/month/gribtab_NLDAS_NOAH.002.txt",
                  sep="")
RSaveFile="'NLDAS_NOAH_month_SOILM.Rdata'"
MatfileDir="./Matfile_NLDAS/"


flag=0

for(y in year){
  folder = paste(dir,toString(y),"/", sep="") 
  filelist = list.files(folder, pattern = "?.grb$", full.names = TRUE)  
  for(file in filelist){    
    data=readGDAL(file)
    tstr=strsplit(file,"\\.",)[[1]][2] #in case no . in file directory
    tt=as.numeric(substr(tstr,2,7))    
    
    if(flag==0){
      flag=1
      crd=coordinates(data)
      SOILM=data$band23
      t=tt
    }
    else{
      SOILM=cbind(SOILM,data$band23)
      t=c(t,tt)
    }
    gc(verbose = getOption("verbose"), reset = FALSE)
  }
  cat(folder,"\n")
}

save(crd,t,SOILM,file=RSaveFile)

matfile=paste(MatfileDir,ProductName,"/SOILM.mat",sep="")
writeMat(matfile,crd=crd,t=t,SOILM=SOILM)
