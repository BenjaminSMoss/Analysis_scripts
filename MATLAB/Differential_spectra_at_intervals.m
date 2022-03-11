clc
%imput SEC_DOD data with iR correction 
filename1='test-4SEC0.964VsmoothDOD_iR_interval_0.02V_increment';
filename=strcat(filename1,'.csv');
Data=readmatrix(filename);
Potential_array=Data(1,2:end);
Wavelength_array=Data(2:end,1);
Spectra=Data(2:end,2:end);
length=length(Wavelength_array);
% add a zero colum in the initial and delete the final cloum
Reference=[(zeros(length,1)),Spectra];
Reference=Reference(:,1:end-1);

%subtract spectra with the one before

Spectra_difference=Spectra-Reference;
Spectra_differenceNorm=normalize(Spectra_difference,'norm',Inf);
%Plot
figure(1)
S=plot(Wavelength_array,Spectra_difference');
figure(2)
S2=plot(Wavelength_array,Spectra_differenceNorm');

%write data
Wavelength_array=[0;Wavelength_array];
Potential_and_spectra=[Potential_array;Spectra_difference];
Differential_data=[Wavelength_array,Potential_and_spectra];
filenameFin=strcat(filename1,'DIFF.csv');
writematrix(Differential_data,filenameFin);
clear
