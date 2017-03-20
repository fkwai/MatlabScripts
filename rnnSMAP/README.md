# rnnSMAP
code in this folder will do:
1. read SMAP predictions from LSTM code running in linux server
2. read forcing database and predict SMAP using LR, LRpbp, NN, NNpbp.
3. compute statatics between observation and predictions using multiple methods
4. plot boxplot and map of time series of results. 
---
## database 
#### database for CONUS is saved:
- In workstation:\
E:\Kuai\rnnSMAP\Database\Daily\CONUS
- In Linux Server:\
/mnt/sdb1/rnnSMAP/database/CONUS
#### database contains:
##### date.csv
dates of all time steps (520) in yyyymmdd
##### crd.csv
coordinate of all grids (12540). Column 1 for latitude and column2 for longitude. Each row refers a grid.
##### forcing 
each variable is described by two files: **var.csv** and **var_stat.csv**. For example, SMAP.csv and SMAP_stat.csv\
- **var.csv**: of size [520*12540], each column is one grid and each row is one time step. \
- **var_stat.csv**: contains 4 numbers for lower bound (value of 10% in CONUS), upper bound (value of 90% in CONUS), mean and var. 
##### constant attribute 
also two files: **const_var.csv** and **const_var_stat.csv**. For example, const_NDVI.csv and const_NDVI_stat.csv\
- **const_var.csv**: of size 12540, and each row is one grid. \
- **const_var_stat.csv**: same as forcing. 
---

### read LSTM prediction
