using Plots: display, string
using LinearAlgebra: size
using LinearAlgebra
using Base: Float64
using CSV
using Glob
using DataFrames
using SavitzkyGolay # to add go to add https://github.com/lnacquaroli/SavitzkyGolay.jl
using Plots
using LinearAlgebra
include("SEC_functions_class.jl")
code_path=pwd()
#This script will do the SG smoothing and adjacent averaging of PD data
#*********************INPUT VALUES

# you must to replace \ pasted from windows with \\ in the path
File_path=raw"C:\Users\B\Box\CoFe-PB-project2\SEC\CoOOH\2022-1-18-Co-CoFeOOH\Co\PD"
filename="1p1OSP-SP"
WL_name="WL.csv"
WL_Min=460
WL_Max=850
t_0_threshold=30
t_window_percent=15
smoothing_weight=71
adj_averaging_window_nm=10


#import data
cd(File_path)
full_data=CSVtoMatrix(filename) # outputs an object with cats x, y, z
Data=full_data.z
times0=full_data.y
times=times0[2:end] #remove the padding zero from the potentials array
#import WL data to use separatly
WL0=CSV.read(WL_name, DataFrame)
WL=WL0[:,1] # WL0 is a DataFrame


# output of this fn is a tuple of matrixes [x_ROI, DATA_ROI,x indexes of ROI] note the x array is assumed to be 
# one unit longer  (due to labview issue on kymera) than the data, so 1 has been subtraced from the indexes array
x_ROI_Tuple=Get_x_Range(WL_Max,WL_Min,Data,WL) 
WL_ROI=x_ROI_Tuple[1]
Data_ROI=x_ROI_Tuple[2]
WL_indexes=x_ROI_Tuple[3]

DOD_tuple=PD_Calculate_DOD_and_smooth(t_0_threshold,Data_ROI,times,smoothing_weight)
DOD=DOD_tuple[1]
DOD_smooth=DOD_tuple[2]

AA_window=adj_averaging_window_nm
Data_ROI__=DOD_smooth
WL_ROI__=WL_ROI
Adj_av_tuple=adjacent_average_WL(adj_averaging_window_nm,DOD_smooth,WL_ROI)
WL_downsample=Adj_av_tuple[1]
DOD_smooth_downsample=Adj_av_tuple[2]

name=string(filename,"DOD",".csv")
write_PD_csv(name,WL_ROI,times0,DOD)

name_S=string(filename,"_DOD_smooth",".csv")
write_PD_csv(name_S,WL_ROI,times0,DOD_smooth)
#PD_plot(DOD_smooth,WL_ROI)

name_S_D=string(filename,"_DOD_smooth_downsample",".csv")
write_PD_csv(name_S_D,WL_downsample,times0,DOD_smooth_downsample)
PD_plot(DOD_smooth_downsample,WL_downsample)
cd(code_path)


