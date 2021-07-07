using Plots: display, string
using LinearAlgebra: size
using LinearAlgebra
using Base: Float64
using CSV
using Glob
using DataFrames
using SavitzkyGolay # to add go to https://github.com/lnacquaroli/SavitzkyGolay.jl
using Plots
using LinearAlgebra
include("SEC_functions_class.jl")

#*********************INPUT VALUES

filename="2h3-NIR-run5SEC"
WL_name="WL-NIR.csv"
WL_Max=1050
WL_Min=800
E_ref=1.09
RHE_conv_factor=0.0
E_ref_RHE=E_ref+RHE_conv_factor
smoothing_weight=51

#*******Referance multiple potentials
Multi_referance=true
timestamp=true # Set true/false
 # not including E_ref
E1=1.3
E2=1.5
E3=1.75
Refs=[E_ref;E1;E2;E3]
Number_of_refs=size(Refs)[1]

#import data
full_data=CSVtoMatrix(filename) # outputs an object with cats x, y, z
Data=full_data.z
potentials=full_data.y
potentials=potentials[2:end] #remove the padding zero from the potentials array
#import WL data to use separatly
WL0=CSV.read(WL_name, DataFrame)
WL=WL0[:,1]


#The FOLLOWING INTRODUCES A ca. 1 nm ERROR (compare lengths OF WL AND DATA)
# THIS IS FINE FOR MY PURPOSES BUT YOU MAY WISH TO ADDRESS THE COMPARE
# ERROR IN LABVIEW AND MODIFY THIS  SCRIPT ACCORDINGLY


 # output of this fn is a tuple of matrixes [x_ROI, DATA_ROI,x indexes of ROI] note the x array is assumed to be 
 # one unit longer  (due to labview issue on kymera) than the data, so 1 has been subtraced from the indexes array
x_ROI_Tuple=Get_x_Range(WL_Max,WL_Min,Data,WL) 
WL_ROI=x_ROI_Tuple[1]
Data_ROI=x_ROI_Tuple[2]
WL_indexes=x_ROI_Tuple[3]


 
y_ROI_Tuple=Get_y_Range(potentials[end],E_ref_RHE,Data_ROI,potentials)
potentials=y_ROI_Tuple[1] #we overwrite as we want to start from the ref potential
Data_ROI=y_ROI_Tuple[2] # we overwrite as we want to start from the ref potential
E_ref_index_all=y_ROI_Tuple[3] # first padding 0 from array is also removed here


DOD_tuple=Calculate_DOD_and_smooth(E_ref_RHE,Data_ROI,potentials,smoothing_weight)
DOD=DOD_tuple[1]
DOD_smooth=DOD_tuple[2]

println("Progress: before plot generation")

if Multi_referance==false

  
   Re_ref_tuple=ReRefDOD_plot(DOD_smooth,WL_ROI,potentials,potentials[end],Refs[1])
   name=Re_ref_tuple[4]
   Name_Final=DateAndTime(name_ref)
   write_data_csv(Name_Final,Re_ref_tuple,WL_ROI)
 # get region Plots
 else 
   println("Progress: before plot loop")

  
   for i=1:Number_of_refs
      
      if i==1
         local  Re_ref_tuple=ReRefDOD_plot(DOD_smooth,WL_ROI,potentials,potentials[end],Refs[1])
         name_ref=Re_ref_tuple[4]
         local Name_Final=DateAndTime(name_ref)
         write_data_csv(Name_Final,Re_ref_tuple,WL_ROI)


         local Re_ref_tuple=ReRefDOD_plot(DOD_smooth,WL_ROI,potentials,potentials[end],Refs[1])
         name_ref=Re_ref_tuple[4]
         local  Name_Final=DateAndTime(name_ref)
          write_data_csv(Name_Final,Re_ref_tuple,WL_ROI)

          local Re_ref_tuple=ReRefDOD_plot(DOD_smooth,WL_ROI,potentials,Refs[2],Refs[1])
         name_ref=Re_ref_tuple[4]
         local Name_Final=DateAndTime(name_ref)
          write_data_csv(Name_Final,Re_ref_tuple,WL_ROI)
      elseif i==Number_of_refs
         local Re_ref_tuple=ReRefDOD_plot(DOD_smooth,WL_ROI,potentials,potentials[end],Refs[i])
         name_ref=Re_ref_tuple[4]
         local Name_Final=DateAndTime(name_ref)
         write_data_csv(Name_Final,Re_ref_tuple,WL_ROI)

      else 
         Re_ref_tuple=ReRefDOD_plot(DOD_smooth,WL_ROI,potentials,Refs[i+1],Refs[i])
         name_ref=Re_ref_tuple[4]
         Name_Final=DateAndTime(name_ref)
         write_data_csv(Name_Final,Re_ref_tuple,WL_ROI)

      end 
     

   end        
end 
 println("Progress: end")
