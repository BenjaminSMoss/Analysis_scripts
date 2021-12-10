%Enter the value of the reference potential 
baseline_potential_AgAgCl = 0.71; %in AgAgCl
RHE_conv_factor=0.96;
smoothing_weight=600;
WL_max=105;
WL_min=350;
filename1='28-run2-2SEC';
filename=strcat(filename1,'.csv');

% read data
SEC_data_array  = csvread(filename);

% Trim the array - remove outlying wavelengths
wavelengths_array0 = SEC_data_array(:,1);
WL_TF=wavelengths_array0>WL_min & wavelengths_array0<WL_max;
data_array=SEC_data_array(WL_TF,2:end);
wavelengths_array = wavelengths_array0(WL_TF);

% get the potentials - note removing the padding zero from first value
potentials_array= SEC_data_array(1,2:end);
potentials_array_RHE= potentials_array+RHE_conv_factor;
baseline_potential = baseline_potential_AgAgCl+RHE_conv_factor;
%Find position of reference potential in array
c = ismember(potentials_array_RHE, baseline_potential);
indexes = find(c);
Ref_potential_check=potentials_array_RHE(c);
potentials_array2=potentials_array_RHE>=Ref_potential_check;
%get the potentials after the ref potential note the transpose at the end
potentials_array2=potentials_array_RHE(potentials_array2)';

% get referance array for DOD using logical indexing

Ref_array=data_array(:,c);
log_RA=log10(Ref_array);

% calculate DOD array
N=size(data_array);
N=N(2);

for i=1:N
    
    DOD(:,i)=-log10(data_array(:,i))+log_RA;
   
    DOD_smooth(:,i)=smooth(DOD(:,i),smoothing_weight,'sgolay',3);
end   
% get the data region that is more than the ref potential
output_data=DOD(:,indexes:end);
output_dataS=DOD_smooth(:,indexes:end);

%Plot data
columns = size(output_data);
columns = columns(2);
set(0,'DefaultAxesColorOrder',jet(columns))

plot(wavelengths_array,output_data,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',20);
set(gca,'linew',3);
set(gcf,'color','w');
axis square

% plot smoothed spectra
tite=num2str(baseline_potential);
tite=strcat('Spectrum vs.',tite,' V RHE' );
figure
plot(wavelengths_array,output_dataS,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',20);
set(gca,'linew',3);
xlim([WL_min+50 WL_max-50]);
leg=num2str(potentials_array2);
title(tite, 'fontsize', 12);
legend(leg);
lgd.FontSize = 12;
lgnd.BoxFace.ColorType='truecoloralpha';
lgnd.BoxFace.ColorData=uint8(255*[1 1 1 0.75]');
set(gcf,'color','w');
axis square



figure
surface(potentials_array2,wavelengths_array,output_dataS,'EdgeColor','none');
xlabel('Applied potential (V vs RHE)', 'FontSize', 25)
set(gcf,'color','w');
set(gca,'Fontsize',20);
ylabel('Wavelength (nm)', 'FontSize', 25)
colorbar()
axis square

%title('SEC data summary')

% put it all together
Final=[potentials_array_RHE;DOD];
% add a padding 0 to WL to match dimensions
wavelengths_array=[0;wavelengths_array];
Final=[wavelengths_array,Final];

FinalS=[potentials_array_RHE;DOD_smooth];
FinalS=[wavelengths_array,FinalS];

fileN=strcat(filename1,'DOD.csv');
fileNS=strcat(filename1,'smooth','DOD.csv');

csvwrite(fileN,Final);
csvwrite(fileNS,FinalS);

clear
clc


