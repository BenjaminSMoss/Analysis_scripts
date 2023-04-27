clc
%imput SEC_DOD data with iR correction 
filename1='2-SEC-0p5-1p6-0p01SEC1.11VsmoothDOD_iR_interval_25mVs';
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
Potential_and_spectraN=[Potential_array;Spectra_differenceNorm];

Differential_data=[Wavelength_array,Potential_and_spectra];
Differential_dataN=[Wavelength_array,Potential_and_spectraN];

filenameFin=strcat(filename1,'DIFF.csv');
filenameFinN=strcat(filename1,'DIFF-NORM.csv');

writematrix(Differential_data,filenameFin);
writematrix(Differential_dataN,filenameFinN);

clear
