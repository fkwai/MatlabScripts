library("rgdal")
library("sp")
library("R.matlab")

t=NULL
crd=NULL
soilm_0_200=NULL
soilm_0_100=NULL
soilm_0_10=NULL
soilm_10_40=NULL
soilm_40_100=NULL
soilm_100_200=NULL

for (y in 1994:2014){
  if (y!=2014){    
    for (m in 1:12){
      if (m>9){
        filename=paste("../NLDAS_data/month//NOAH//",
                       toString(y),
                       "//NLDAS_NOAH0125_M.A",
                       toString(y),toString(m),
                       ".002.grb", sep="") 
        
      }else{
        filename=paste("../NLDAS_data/month//NOAH//",
                       toString(y),
                       "//NLDAS_NOAH0125_M.A",
                       toString(y),"0",toString(m),
                       ".002.grb", sep="")         
      }              
      
      data=readGDAL(filename)
      
      crd=coordinates(data)
      crd.df=data.frame(crd)
      crd.sub=subset(crd.df,x>=-128&x<=-60&y>=20&y<=50)
      index=as.numeric(row.names(crd.sub))
      
      soilm_0_200=cbind(soilm_0_200,data$band23[index])
      soilm_0_100=cbind(soilm_0_100,data$band25[index])
      soilm_0_10=cbind(soilm_0_10,data$band26[index])
      soilm_10_40=cbind(soilm_10_40,data$band27[index])
      soilm_40_100=cbind(soilm_40_100,data$band28[index])
      soilm_100_200=cbind(soilm_100_200,data$band29[index])
      tint=y*10000+m*100+1;
      t=rbind(t,tint)
    }    
  } else {
    for (m in 1:9){
      filename=paste("../NLDAS_data/month//NOAH//",
                     toString(y),
                     "//NLDAS_NOAH0125_M.A",
                     toString(y),"0",toString(m),
                     ".002.grb", sep="") 
      
      data=readGDAL(filename)
      
      crd=coordinates(data)
      crd.df=data.frame(crd)
      crd.sub=subset(crd.df,x>=-128&x<=-60&y>=20&y<=50)
      index=as.numeric(row.names(crd.sub))
      
      soilm_0_200=cbind(soilm_0_200,data$band23[index])
      soilm_0_100=cbind(soilm_0_100,data$band25[index])
      soilm_0_10=cbind(soilm_0_10,data$band26[index])
      soilm_10_40=cbind(soilm_10_40,data$band27[index])
      soilm_40_100=cbind(soilm_40_100,data$band28[index])
      soilm_100_200=cbind(soilm_100_200,data$band29[index])
      tint=y*10000+m*100+1;
      t=rbind(t,tint)
      
    } 
  }
}
matfile="NOAH_month_USA.mat";
writeMat(matfile,t=t, crd=crd.sub, 
         soilm_0_200=soilm_0_200,
         soilm_0_100=soilm_0_100, 
         soilm_0_10=soilm_0_10,
         soilm_10_40=soilm_10_40,
         soilm_40_100=soilm_40_100,
         soilm_100_200=soilm_100_200)