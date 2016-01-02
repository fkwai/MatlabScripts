buildTab <-function(AttrFile,GribtabFile){
  AttrText = readLines(AttrFile)
  attr=strsplit(AttrText,":")
  indkpds=grep("kpds",attr[[1]])
  nvar=length(attr)
  nattr=length(attr)
  AttrTable=matrix(,nrow=nvar,ncol=2)
  for(i in 1:nattr){
    attrstr=attr[[i]][indkpds]
    attrstr=strsplit(attrstr,"=")[[1]][2]
    attrstr=strsplit(attrstr,",")
    AttrTable[i,1]=as.numeric(attrstr[[1]][1])
    AttrTable[i,2]=as.numeric(attrstr[[1]][3])
  }
  
  GribtabText=readLines(GribtabFile)
  gribtab=strsplit(GribtabText,":")
  gribtab=gribtab[2:length(gribtab)]
  RefTable=data.frame(matrix(unlist(gribtab),
                             nrow=length(gribtab), byrow=TRUE))
  names(RefTable) = c("kpds", "field","explaination")
  RefTable$kpds=as.numeric(levels(RefTable$kpds))[RefTable$kpds]
  
  rlst=list("AttrTable"=AttrTable,"RefTable"=RefTable)
  
  return(rlst)
}
 

readHDF_NLDAS_hourly<-function(FLtxt){
  library("rgdal")
  
  filelist=readLines(FLtxt)
  datalst=list()
  flag=0
  for(file in filelist){ 
    print(paste("processing: ",file,sep=""))
    data=readGDAL(file)
    tstr=strsplit(file,"\\.",)[[1]][2] #in case no . in file directory
    hstr=strsplit(file,"\\.",)[[1]][3] 
    tt=as.numeric(substr(tstr,2,7)) 
    hh=as.numeric(substr(hstr,2,7))  
    
    if(flag==0){
      flag=1
      crd=coordinates(data)
      size=dim(data)
      nattr=size[2]
      for(i in 1:nattr){
        evalstr=paste("d",as.numeric(i),"=","data$band",as.numeric(i),sep="")
        eval(parse(text=evalstr))      
      } 
      t=tt
      h=hh
    }
    else{
      for(i in 1:nattr){
        evalstr=paste("d",as.numeric(i),"=",
                      "cbind(d",as.numeric(i),",data$band",as.numeric(i),")",sep="")
        eval(parse(text=evalstr))           
      }
      t=c(t,tt)
      h=c(h,hh)
    }
    gc(verbose = getOption("verbose"), reset = FALSE)
  }
  for(i in 1:nattr){
    evalstr=paste("datalst$d",as.numeric(i),"=","d",as.numeric(i),sep="")
    eval(parse(text=evalstr))   
  }
  datalst$crd=crd
  datalst$t=t
  datalst$h=h
  return(datalst)
}

readHDF_NLDAS_daily<-function(FLtxt){
  library("rgdal")
  
  filelist=readLines(FLtxt)
  datalst=list()
  
  data=readGDAL(filelist[1])
  crd=coordinates(data)
  size=dim(data)
  nattr=size[2]
  
  for(i in 1:nattr){
    evalstr=paste("d",as.numeric(i),"=NULL",sep="")
    eval(parse(text=evalstr))      
    evalstr=paste("td",as.numeric(i),"=NULL",sep="")
    eval(parse(text=evalstr))     
  }
  tdate=NULL
  
  for(file in filelist){ 
    print(paste("processing: ",file,sep=""))
    data=readGDAL(file)
    tstr=strsplit(file,"\\.",)[[1]][2] #in case no . in file directory
    hstr=strsplit(file,"\\.",)[[1]][3] 
    tt=as.numeric(substr(tstr,2,9)) 
    hh=as.numeric(substr(hstr,1,2))    
    
    if(hh!=21){
      for(i in 1:nattr){
        evalstr=paste("td",as.numeric(i),"=",
                      "cbind(td",as.numeric(i),",data$band",as.numeric(i),")",sep="")
        eval(parse(text=evalstr))  
      }
    }
    if(hh==21){ 
      for(i in 1:nattr){
        evalstr=paste("d",as.numeric(i),"=",
                      "cbind(d",as.numeric(i),",rowMeans(td",as.numeric(i),"))",sep="")
        eval(parse(text=evalstr))  
        evalstr=paste("td",as.numeric(i),"=NULL",sep="")
        eval(parse(text=evalstr))    
      }
      tdate=cbind(tdate,tt)
    }    
    gc(verbose = getOption("verbose"), reset = FALSE)
  }
  
  for(i in 1:nattr){
    evalstr=paste("datalst$d",as.numeric(i),"=","d",as.numeric(i),sep="")
    eval(parse(text=evalstr))   
  }
  datalst$crd=crd
  datalst$tdate=tdate
  return(datalst)
}

saveMatfile<-function(datalst,AttrTable,RefTable,MatSaveFolder){
  nattr=dim(AttrTable)
  nattr=nattr[1]
  
  dir.create(file.path(MatSaveFolder), showWarnings = FALSE)
  
  # correct variable name
  for(i in 1:nattr){
    kpds=AttrTable[i,1]
    append=AttrTable[i,2]
    index=which(c(RefTable[,1]==AttrTable[i,1])) 
    varname=as.character(
      levels(RefTable$field))[RefTable$field][index]
    
    if(length(which(c(AttrTable[,1]==kpds)))>1){
      # this is trying to work with #85 and #86, soil moisture and soil temp
      varname=paste(varname,"_",as.numeric(append),sep="")
    }
    
    matfile=paste(MatSaveFolder,"/",varname,".mat",sep="");
    savestr=paste("writeMat(matfile,crd=datalst$crd,t=datalst$t,h=datalst$h,",
                  varname,"=","datalst$d",as.numeric(i),")",sep="")
    eval(parse(text=savestr)) 
    gc(verbose = getOption("verbose"), reset = FALSE)    
  } 
}

readNLDAS_hourly<-function(FLtxt,AttrFile,GribtabFile,MatSaveFolder){  
  
  tab=buildTab(AttrFile,GribtabFile)
  AttrTable=tab$AttrTable
  RefTable=tab$RefTable
  datalst=readHDF_NLDAS_hourly(FLtxt)
  saveMatfile(datalst,AttrTable,RefTable,MatSaveFolder)
}  

readNLDAS_daily<-function(FLtxt,AttrFile,GribtabFile,MatSaveFolder){  
  
  tab=buildTab(AttrFile,GribtabFile)
  AttrTable=tab$AttrTable
  RefTable=tab$RefTable
  datalst=readHDF_NLDAS_daily(FLtxt)
  saveMatfile(datalst,AttrTable,RefTable,MatSaveFolder)
}  
