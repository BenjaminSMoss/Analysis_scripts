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
 
#This script will do the SG smoothing and adjacent averaging of PD data
#*********************INPUT VALUES
code_path=pwd()
# you must to replace \ pasted from windows with \\ in the path
File_path="C:\\Users\\Benjamin\\Box\\CoFe-PB-project2\\2021-06-23-PB3h-1\\2H2\\PD"
filename="2h2-PD-1p7OSP-SP"
WL_name="WL.csv"
WL_Min=450
WL_Max=800
t_0_threshold=10
t_window_percent=10
smoothing_weight=51
adj_averaging_window_nm=10


#import data
cd(File_path)
full_data=CSVtoMatrix(filename) # outputs an object with cats x, y, z
Data=full_data.z
times=full_data.y
times=times[2:end] #remove the padding zero from the potentials array
#import WL data to use separatly
WL0=CSV.read(WL_name, DataFrame)
WL=WL0[:,1] # WL0 is a DataFrame


# output of this fn is a tuple of matrixes [x_ROI, DATA_ROI,x indexes of ROI] note the x array is assumed to be 
# one unit longer  (due to labview issue on kymera) than the data, so 1 has been subtraced from the indexes array
x_ROI_Tuple=Get_x_Range(WL_Max,WL_Min,Data,WL) 
WL_ROI=x_ROI_Tuple[1]
Data_ROI=x_ROI_Tuple[2]
WL_indexes=x_ROI_Tuple[3]

PD_Calculate_DOD_and_smooth(t_0_threshold,Data,times,smoothing_weight)
DOD=DOD_tuple[1]
DOD_smooth=DOD_tuple[2]

