
library("rgdal")
library("sp")
library("R.matlab")

# modify inquired product and years here

ProductName="NOAH_V2"
year=c(1994:2014)
#dir=paste("E:/work/LDAS/GLDAS_data/V1_month/",
#          ProductName,"/",sep="")
dir=paste("E:/work/LDAS/GLDAS_data/V2_month/","/",sep="")
GribtabFile=paste("E:/work/LDAS/GLDAS_data/gribtab_GLDAS_V2"
                  ,".tab",sep="")
RSaveFile="'GLDAS_V2_month_global.Rdata'"



# create varibles from attribute file generate by wgrib
# assume data of same product is of same formate

AttrText = readLines(paste(dir,"2010/attr.txt",sep=""))
attr=strsplit(AttrText,":")
indkpds=6  #index of kpds, modify based on different product
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



# start reading data

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
      for(i in 1:nattr){
        evalstr=paste("d",as.numeric(i),"=","data$band",as.numeric(i),sep="")
        eval(parse(text=evalstr))      
      } 
      t=tt
    }
    else{
      for(i in 1:nattr){
        evalstr=paste("d",as.numeric(i),"=",
                      "cbind(d",as.numeric(i),",data$band",as.numeric(i),")",sep="")
        eval(parse(text=evalstr))   
        
      }
      t=c(t,tt)
    }
    
    # need garbage collection after each iteration
    gc(verbose = getOption("verbose"), reset = FALSE)
  }
  cat(folder,"\n")
}



# Save it to correct varible name

#VarTable=matrix(,nrow=nvar,ncol=2)

MatSaveFolder=paste("E:/work/LDAS/GLDAS_matfile","/",ProductName,"/",sep="")
dir.create(file.path(MatSaveFolder), showWarnings = FALSE)
for(i in 1:nattr){
  kpds=AttrTable[i,1]
  append=AttrTable[i,2]
  index=which(c(RefTable[,1]==AttrTable[i,1])) 
  
  if(length(index)>1){
    tempind=append-100
    index=index[tempind]    
  }   
  
  varname=as.character(
    levels(RefTable$field))[RefTable$field][index]
  
#   if(length(which(c(AttrTable[,1]==kpds)))>1){
#     # this is trying to work with #85 and #86, soil moisture and soil temp
#     varname=paste(varname,"_",as.numeric(append),sep="")
#   }  
  
  matfile=paste(MatSaveFolder,"/",varname,".mat",sep="");
  savestr=paste("writeMat(matfile,crd=crd,t=t,",
                varname,"=","d",as.numeric(i),")",sep="")
  eval(parse(text=savestr)) 
  gc(verbose = getOption("verbose"), reset = FALSE)   
}


# # Write a Rdata file
# 
# RSaveStr=paste("save(crd,t,VarTable,",sep="")
# for(i in 1:nattr){
#   varname=VarTable[i,1]
#   RSaveStr=paste(RSaveStr,varname,",",sep="")  
# }
# RSaveStr=paste(RSaveStr,"file=",RSaveFile,")",sep="")
# eval(parse(text=RSaveStr))
# 
# 
# # Write to mat file
# 
# for(i in 1:nattr){
#   varname=VarTable[i,1]
#   matfile=paste("./Matfile_GLDAS/",ProductName,"/",
#                 varname,".mat",sep="");
#   savestr=paste("writeMat(matfile,crd=crd,t=t,",
#                 varname,"=",varname,")",sep="")
#   eval(parse(text=savestr)) 
#   
#   # need garbage collection after each iteration
#   gc(verbose = getOption("verbose"), reset = FALSE)
# }

# eval(parse(text=savestr)) # no enough momory space for all data...


# for GLDAS V2:

# TSoil1=d14
# TSoil2=d15
# TSoil3=d16
# TSoil4=d17
# SoilM1=d18
# SoilM2=d19
# SoilM3=d20
# SoilM4=d21
# writeMat("./Matfile_GLDAS/V2/SoilM1.mat",crd=crd,t=t,SoilM1=SoilM1)
# writeMat("./Matfile_GLDAS/V2/SoilM2.mat",crd=crd,t=t,SoilM2=SoilM2)
# writeMat("./Matfile_GLDAS/V2/SoilM3.mat",crd=crd,t=t,SoilM3=SoilM3)
# writeMat("./Matfile_GLDAS/V2/SoilM4.mat",crd=crd,t=t,SoilM4=SoilM4)
# writeMat("./Matfile_GLDAS/V2/TSoil1.mat",crd=crd,t=t,TSoil1=TSoil1)
# writeMat("./Matfile_GLDAS/V2/TSoil2.mat",crd=crd,t=t,TSoil2=TSoil2)
# writeMat("./Matfile_GLDAS/V2/TSoil3.mat",crd=crd,t=t,TSoil3=TSoil3)
# writeMat("./Matfile_GLDAS/V2/TSoil4.mat",crd=crd,t=t,TSoil4=TSoil4)