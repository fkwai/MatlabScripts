
# works for GLDAS/NLDAS data save in original orgination of downloading source. 

#input
year=c(2000:2010)
dir=paste("Y:/GLDAS/V2/GLDAS_NOAH10_3H_020/",sep="") #dir of data

# create FileList folder
dir.create(paste(dir,"/FileList/",sep=""),showWarnings = FALSE)  


# get list of all data
if(exists("filelist_all")){
  rm("filelist_all")  
}
if(exists("filelist")){
  rm("filelist")  
}
for(y in year){
  if((y%%4==0)&(y%%100!=0)){
    day=c(1:366)
  }
  else{
    day=c(1:365)
  }
  for(d in day){
    dstr=formatC(d,width=3,flag="0")
    folder = paste(dir,toString(y),"/",dstr,"/",sep="") 
    if(exists("filelist_all")){
      lst=list.files(folder, pattern = "?.grb$", full.names = TRUE)
      filelist_all=c(filelist_all,lst)
      }else{
        filelist_all = list.files(folder, pattern = "?.grb$", full.names = TRUE)      
      }
  }
}

for (y in year){
  for(m in c(1:12)){
    flname=paste(as.character(y),formatC(m,width=2,flag="0"),
                 "_filelist.txt",sep="")
    # find date seq of loading data
    sd=as.Date(paste(toString(y),"-",toString(m),"-01",sep=""))
    if(m==12){
      ed=as.Date(paste(toString(y+1),"-",toString(1),"-01",sep=""))            
    }else{
      ed=as.Date(paste(toString(y),"-",toString(m+1),"-01",sep=""))      
    }          
    ds=seq(sd,ed, by="day")
    dstr=strftime(ds[1:length(ds)-1],"%Y%m%d")
    if(exists("filelist")){
      rm("filelist")  
    }
    for(i in c(1:length(dstr))){
      if(exists("filelist")){
        filelist=c(filelist,filelist_all[grep(dstr[i],filelist_all)])
      }else{        
        filelist=filelist_all[grep(dstr[i],filelist_all)]
      }
    }
    fltxt=paste(dir,"/FileList/",flname,sep="")
    fileConn<-file(fltxt)
    writeLines(filelist, fileConn)
    close(fileConn)
  }
}
