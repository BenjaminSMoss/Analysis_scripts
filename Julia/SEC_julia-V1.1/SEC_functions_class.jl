using CSV 
using Dates
using DelimitedFiles
using Tables
mutable struct all_data # This defines the object which is the output of the CSVtoMatrix function. 
    x
    y
    z
end

function CSVtoMatrix(fileName) # This takes the file name (no .csv) and outputs an object containing the x-array, the
#y array and the data, note the x and y arrays contain one common element [1,1] of the CSV file, which is typically a zero

    filename2=string(fileName,".csv")
    Data=CSV.read(filename2, DataFrame)

    y_vals=names(Data) # gives string
    y_vals2=parse.(Float64,y_vals[:]) #gives num 
    x_vals=Data[:,1]
    Data=Matrix(Data[2:end,2:end])


    All_data=all_data(x_vals,y_vals2,Data)
    println("Progress: Files read without error")
    return All_data
    
end 


#Takes the filename and creates a string starting with Date and time
function DateAndTime(fileName)
    hour = string(Dates.hour(now()))
    minute = string(Dates.minute(now()))
    date =  string(Dates.today())
    FinalFileName=("$date $hour-$minute $fileName")
    return FinalFileName
end


function Get_x_Range(Max,Min,Data_in,x_array)  # output is a tuple of matrixes [x_ROI, DATA_ROI,x indexes]
    
        if Min>=x_array[2] &&  Max<=x_array[end]     
              x_indexes=findall(x->x>=Min&&x<=Max, x_array)
         else 
             throw(DomainError(x, "the min or max max value is outside the range of the x arrray"))
         end 

    x_indexes1=x_indexes.-1  # Recall that the x array is one element longer than the data darray


# use indexes in x and Data array -

    x_ROI=x_array[x_indexes,:]
    Data_in_ROI=Data_in[x_indexes1,:]

    println("Progress: Get_x_Range, regions of interest found")

    return x_ROI,Data_in_ROI,x_indexes1
end

function Get_y_Range(yMax,yMin,Data_input,y_array)  # output is a tuple of matrixes [y_ROI, DATA_ROI, y indexes]
    
    if yMin>=y_array[1] &&  yMax<=y_array[end] 
            y_ref_index=findall(x->x>=yMin&&x<=yMax, y_array)
            y_ref_index1=y_ref_index
    else 
              throw(DomainError(x, "the min or max max value is outside the range of the y array"))
    end 

    y_array_ROI=y_array[y_ref_index]
    Data_input_ROI=Data_input[:,y_ref_index1]

    println("Progress: Get_y_Range, regions of interest found")

    return y_array_ROI,Data_input_ROI,y_ref_index1
end

function Calculate_DOD_and_smooth(Ref_value,Data_input1,y_array2,smooth_window)  # output is the DOD and DOD smooth matrix with DOD = 0 at Ref_value
    y_ref_value_index=findall(x->x==Ref_value, y_array2)
    I0=Data_input1[:,y_ref_value_index]
    #get array sizes and potential array
    Data_Size=size(Data_input1)
    Number_of_y=Data_Size[2]
    Number_of_x=Data_Size[1]
     
    DOD=zeros(Number_of_x,Number_of_y)
    for i = 1:Number_of_x, j=1:Number_of_y
       DOD[i,j]=log10(I0[i])-log10(Data_input1[i,j])
    end 

    DOD_smooth=zeros(Number_of_x,Number_of_y)
    
    for i = 1:Number_of_y
         DOD_smooth_object= savitzky_golay(DOD[:,i], smooth_window, 4)
         DOD_smooth_i=DOD_smooth_object.y #extract from SG object
         DOD_smooth[:,i]=DOD_smooth_i
    end
    println("Progress: DOD calculated, Data Smoothed")
    return DOD,DOD_smooth
end 

function ReRefDOD_plot(DOD_data,WL_data_,y_data,ymax,ymin)
    
    y_ref_index_1=findall(x->x>=ymin&&x<=ymax, y_data)
    y_data_range=y_data[y_ref_index_1]
    DOD_data_range=DOD_data[:,y_ref_index_1]
  

    number_of_y=size(DOD_data_range)[2]
    number_of_x=size(DOD_data_range)[1]
    DOD_data_range_RR=zeros(number_of_x,number_of_y)
    
        for i=1:number_of_y
            DOD_data_range_RR[:,i]=DOD_data_range[:,i]-DOD_data_range[:,1]
        end 
    
    upper_="$ymax"
    lower_="$ymin"

        gr()     
        display(
            plot(
                    WL_data_,DOD_data_range_RR,
                    linewidth=5,
                    palette = :linear_bgyw_15_100_c67_n256,		
                    legend = false,
                    title = "Spectra to $upper_ V RHE",
                    xlabel = "Wavelength (nm)",
                    ylabel = "Delta A vs $lower_ V RHE"
                )
            )

    println("Progress:  Referanced to $lower_ and plotted")
    descriptor_string=string(lower_,"to",upper_,"SEC",".csv")
    return y_data_range,DOD_data_range_RR,y_ref_index_1,descriptor_string
end
    
function write_data_csv(name,Data_tuple,x_range_final)

   dataY=Data_tuple[1]'
   dataZ=Data_tuple[2]
   WL=[0;x_range_final]
   Final=[dataY;dataZ]
   Final=[WL Final]
  
    writedlm(name,  Final, ',')
    println("Progress: $name  written to csv")
end 


function PD_Calculate_DOD_and_smooth(t0_value,Data_input1__,y_array__,smooth_window__)  # output is the DOD and DOD smooth matrix with DOD = 0 at Ref_value
    t0_index=findall(x->x<=t0_value, y_array__)
    I0=mean(Data_input1__[:,t0_index], dims=2) # average along time before t0
    #get array sizes and potential array
    Data_Size=size(Data_input1__)
    Number_of_y=Data_Size[2]
    Number_of_x=Data_Size[1]
     
    DOD=zeros(Number_of_x,Number_of_y)
    for i = 1:Number_of_x, j=1:Number_of_y
       DOD[i,j]=log10(I0[i])-log10(Data_input1__[i,j])
    end 

    DOD_smooth=zeros(Number_of_x,Number_of_y)
    
    for i = 1:Number_of_y
         DOD_smooth_object= savitzky_golay(DOD[:,i], smooth_window__, 4)
         DOD_smooth_i=DOD_smooth_object.y #extract from SG object
         DOD_smooth[:,i]=DOD_smooth_i
    end
    println("Progress: DOD calculated, Data Smoothed")
    return DOD,DOD_smooth
end 