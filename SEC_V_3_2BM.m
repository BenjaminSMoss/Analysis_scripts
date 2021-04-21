%Enter the value of the reference potential 
baseline_potential = 0.5;
filename1='test-4SEC';
filename=strcat(filename1,'.csv');
%Enter the filename for the SEC data
SEC_data_array  = csvread(filename);

%Find potential and wavelength data from arrays
% get data array also removing padding 0 from potential array
potentials_array  = SEC_data_array(1,2:end);
wavelengths_array = SEC_data_array(:,1);
data_array= SEC_data_array(2:end,2:end);

%Find position of reference potential in array
c = ismember(potentials_array, baseline_potential);
indexes = find(c);

Ref_potential_check=potentials_array(c);

% get regerance array using logical indexing

Ref_array=data_array(:,c);
log_RA=log10(Ref_array);

% calculate DOD array
N=size(data_array);
N=N(2);

for i=1:N
    
    DOD(:,i)=-log10(data_array(:,i))+log_RA;
end 
N=size(data_array);
N=N(2);
for  i=1:N
    
    DOD_smooth(:,i)=smooth(DOD(:,i),50,'sgolay',3);
end   
% get the data region that is more than the ref potential
output_data=DOD(:,indexes:end);
output_dataS=DOD_smooth(:,indexes:end);
% remove leading zero from WL array
output_wavelength=wavelengths_array(2:end);
%Plot data
columns = size(output_data);
columns = columns(2);
set(0,'DefaultAxesColorOrder',jet(columns))

plot(output_wavelength,output_data,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',20);
xlim([350 1050]);
set(gca,'linew',3);


figure
plot(output_wavelength,output_dataS,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',20);
xlim([350 1050]);
set(gca,'linew',3);
%title('SEC data summary')
% put it all together
WL = SEC_data_array(:,1);
Final=[potentials_array;DOD];
Final=[WL,Final];

FinalS=[potentials_array;DOD_smooth];
FinalS=[WL,FinalS];

fileN=strcat(filename1,'DOD.csv');
fileNS=strcat(filename1,'smooth','DOD.csv');

csvwrite(fileN,Final);
csvwrite(fileNS,FinalS);

clear
clc


