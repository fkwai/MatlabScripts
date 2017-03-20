# rnnSMAP
code in this folder will do:
1. read SMAP predictions from LSTM code running in linux server
2. read forcing database and predict SMAP using LR, LRpbp, NN, NNpbp.
3. compute statatics between observation and predictions using multiple methods
4. plot boxplot and map of time series of results. 

main script [script_testRnnSMAP.m](./script_testRnnSMAP.m)
***

# database 
## database location
- In workstation:\
E:\Kuai\rnnSMAP\Database\Daily\CONUS
- In Linux Server:\
/mnt/sdb1/rnnSMAP/database/CONUS
## database content
### date.csv
dates of all time steps (520) in yyyymmdd
### crd.csv
coordinate of all grids (12540). Column 1 for latitude and column2 for longitude. Each row refers a grid.
### forcing 
each variable is described by two files: **var.csv** and **var_stat.csv**. For example, SMAP.csv and SMAP_stat.csv\
- **var.csv**: of size [520*12540], each column is one grid and each row is one time step. \
- **var_stat.csv**: contains 4 numbers for lower bound (value of 10% in CONUS), upper bound (value of 90% in CONUS), mean and var. 
### constant attribute 
also two files: **const_var.csv** and **const_var_stat.csv**. For example, const_NDVI.csv and const_NDVI_stat.csv\
- **const_var.csv**: of size 12540, and each row is one grid. \
- **const_var_stat.csv**: same as forcing. 
## subset of database
subset of databset is saved in another folder. For example **E:\Kuai\rnnSMAP\Database\Daily\CONUS_sub4**
### code to divide subset:
divide subset by interval: [splitSubset_interval.m](./splitSubset_interval.m)
divide subset by NDVI, LULC, divisions: **not updated yet**
## construct database
### raw data: 
SMAP and GLDAS matfiles
- Y:\GLDAS\Hourly\GLDAS_NOAH_mat\ (GLDAS)
- Y:\SMAP\SMP_L2_q (SMAP)
- /mnt/sdb1/rnnSMAP/matfile (uploaded to Linux server)
### code of raw data to csv
- function: [GLDAS2csv_CONUS.m](./GLDAS2csv_CONUS.m)
- script: [grid2csv_CONUS_script.m](./grid2csv_CONUS_script.m)
***

# read LSTM prediction
## LSTM prediction format
example: E:\Kuai\rnnSMAP\output\test \ 
LSTM prediction contains three items:
- folder of predictions (out_trainName_testName_epoch)\
for example out_CONUS_sub16_CONUS_sub16_500\ 
prediction of training set and testing set are saved by batch
- saved model (Par_trainName_epoch.csv) \
for example Par_CONUS_sub16_epoch500.csv\ 
- training error of all epochs (runFile.csv)

## read prediction
[readRnnPred.m](./readRnnPred.m)
***

# regress using conventional methods
main script [testRnnSMAP_readData.m](./testRnnSMAP_readData.m)
## read database
[readDatabaseSMAP2.m](./readDatabaseSMAP2.m)
## regress using conventional methods
linear regression: [regSMAP_LR.m](./regSMAP_LR.m)
linear regression pbp: [regSMAP_LR_solo.m](./regSMAP_LR_solo.m)
NN: [regSMAP_NN.m](./regSMAP_NN.m)
NN pbp: [regSMAP_NN_solo.m](./regSMAP_NN_solo.m)
***

# compute statatics
main script [testRnnSMAP_plot.m](./testRnnSMAP_plot.m)
function [statCal.m](./statCal.m)
***

# plot
## box plot
function [statBoxPlot.m](./statBoxPlot.m)
## map 
script [testRnnSMAP_map.m](./testRnnSMAP_map.m) **not updated yet**

