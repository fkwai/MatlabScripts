library("rgdal")
library("sp")
library("R.matlab")

t=NULL
crd=NULL
prcp=NULL
pet=NULL

for (y in 1994:2014){
  if (y!=2014){    
    for (m in 1:12){
      if (m>9){
        filename=paste("../NLDAS_data/month//FORA//",
                       toString(y),
                       "//NLDAS_FORA0125_M.A",
                       toString(y),toString(m),
                       ".002.grb", sep="") 
        
      }else{
        filename=paste("../NLDAS_data/month//FORA//",
                       toString(y),
                       "//NLDAS_FORA0125_M.A",
                       toString(y),"0",toString(m),
                       ".002.grb", sep="")         
      }              
      
      data=readGDAL(filename)
      
      crd=coordinates(data)
      crd.df=data.frame(crd)
      crd.sub=subset(crd.df,x>=-128&x<=-60&y>=20&y<=50)
      index=as.numeric(row.names(crd.sub))
      
      
      prcp=cbind(prcp,data$band10[index])
      pet=cbind(pet,data$band9[index])
      tint=y*10000+m*100+1;
      t=rbind(t,tint)
    }    
  } else {
    for (m in 1:9){
      filename=paste("../NLDAS_data/month//FORA//",
                     toString(y),
                     "//NLDAS_FORA0125_M.A",
                     toString(y),"0",toString(m),
                     ".002.grb", sep="") 
      
      data=readGDAL(filename)
      
      crd=coordinates(data)
      crd.df=data.frame(crd)
      crd.sub=subset(crd.df,x>=-128&x<=-60&y>=20&y<=50)
      index=as.numeric(row.names(crd.sub))
      
      prcp=cbind(prcp,data$band10[index])
      pet=cbind(pet,data$band9[index])
      tint=y*10000+m*100+1;
      t=rbind(t,tint)
      
    } 
  }
}
matfile="FORA_month_USA.mat";
writeMat(matfile,t=t, crd=crd.sub, 
         prcp=prcp,
         pet=pet)