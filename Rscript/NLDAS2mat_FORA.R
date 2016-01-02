
library("rgdal")
library("sp")
library("R.matlab")

# modify inquired product and years here

ProductName="FORA"
year=c(1994:2003)
dir=paste("E:/work/LDAS/NLDAS_data/month/",ProductName,"/",sep="")
GribtabFile=paste("E:/work/LDAS/NLDAS_data/month/gribtab_NLDAS_FORA_monthly.002.txt",
                  sep="")
RSaveFile="'NLDAS_FORA_month_1994.Rdata'"
#MatfileDir="./Matfile_NLDAS/"
MatfileDir="E:/work/MOPEX/"



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
    gc(verbose = getOption("verbose"), reset = FALSE)
  }
  cat(folder,"\n")
}



# Save it to correct varible name


VarTable=matrix(,nrow=nvar,ncol=2)

for(i in 1:nattr){
  kpds=AttrTable[i,1]
  append=AttrTable[i,2]
  index=which(c(RefTable[,1]==AttrTable[i,1])) 
  varname=as.character(
    levels(RefTable$field))[RefTable$field][index]
  
  if(length(which(c(AttrTable[,1]==kpds)))>1){
    # this is trying to work with #85 and #86, soil moisture and soil temp
    varname=   paste(varname,"_",as.numeric(append),sep="")
  }
  
  evalstr=paste(varname,"=","d",as.numeric(i),sep="")
  eval(parse(text=evalstr))
  
  VarTable[i,1]=varname
  VarTable[i,2]=as.character(
    levels(RefTable$explaination))[RefTable$explaination][index]
}
VarTable=data.frame(VarTable)
names(VarTable)=c("Field","Explaination")




# Write a Rdata file

RSaveStr=paste("save(crd,t,VarTable,",sep="")
for(i in 1:nattr){
  varname=VarTable[i,1]
  RSaveStr=paste(RSaveStr,varname,",",sep="")  
}
RSaveStr=paste(RSaveStr,"file=",RSaveFile,")",sep="")
eval(parse(text=RSaveStr))


# Write to mat file

for(i in 1:nattr){
  varname=VarTable[i,1]
  matfile=paste(MatfileDir,ProductName,"/",
                varname,".mat",sep="");
  savestr=paste("writeMat(matfile,crd=crd,t=t,",
                varname,"=",varname,")",sep="")
  eval(parse(text=savestr)) 
  
  # need garbage collection after each iteration
  gc(verbose = getOption("verbose"), reset = FALSE)
}