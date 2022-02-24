#this uses the output of the Spectral model code

potentials=y'
FitValues=paramOpt
#the orig. spectra are pureZ
number_of_potentials=size(paramOpt)[1]
number_of_pure_spectra=size(paramOpt)[2]
number_of_wavelengths=size(pureZ)[1]
Pure_spectra_E=zeros(number_of_wavelengths,number_of_pure_spectra)
Reconstructed_spectrum=zeros(number_of_wavelengths,number_of_potentials)

for  i=1:number_of_potentials
    for j=1:number_of_pure_spectra
    Pure_spectra_E[:,j]=pureZ[:,j].*FitValues[i,j]
    end 
    Reconstructed_spectrum[:,i]=sum(Pure_spectra_E,dims=2)
end 

residuals=z.-Reconstructed_spectrum
 
WL=[0;x]

final=[potentials;Reconstructed_spectrum]

final=[WL final]

Residuals_final=[potentials;residuals]
Residuals_final=[WL Residuals_final]
#=
gr()  

    plot(
            x,Reconstructed_spectrum[:,[1:20:700;]],
            linewidth=1,
            palette = :linear_bgyw_15_100_c67_n256,		
            legend = false,
            title = "PD spectra",
            xlabel = "Wavelength (nm)",
            ylabel = "Delta A vs t0",
            markersize=0,
        )
    

  
    plot(
            x,residuals[:,[1:20:800;]],
            linewidth=1,
            palette = :linear_bgyw_15_100_c67_n256,		
            legend = false,
            title = "PD spectra",
            xlabel = "Wavelength (nm)",
            ylabel = "Delta A vs t0",
            markersize=0
        )
    =#
writedlm("Reconstructed_spectrum.csv",final,',')
writedlm("residuals.csv",Residuals_final,',')



