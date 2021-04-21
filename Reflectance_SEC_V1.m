%Enter the value of the reference potential 
baseline_potential = 0.2;
filename1='test7SEC';
filename2='0RSEC';
filename3='100RSEC';
filename4='WL';
filename_=strcat(filename1,'.csv');
filename2_=strcat(filename2,'.csv');
filename3_=strcat(filename3,'.csv');
filename4_=strcat(filename4,'.csv');
%Get data and referance files
SEC_data_array  = csvread(filename_);
SEC_data_array_0R  = csvread(filename2_);
SEC_data_array_100R  = csvread(filename3_);
wavelengths_array =csvread(filename4_);
wavelengths_array=wavelengths_array(:,1);
wavelengths_array=wavelengths_array(3:end);

%average 100R and 0R arrays
data_0R=mean(SEC_data_array_0R(2:end,2:end),2);
data_100R=mean(SEC_data_array_100R(2:end,2:end),2);
data_100R_Zeroed=data_100R-data_0R;
data=SEC_data_array(2:end,2:end);

% plot raw data for sanity check

comare_aray=[data(:,1),data_0R,data_100R];
figure
plot(wavelengths_array,comare_aray,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('counts')
set(gca,'Fontsize',20);
xlim([350 1050]);
set(gca,'linew',3);


%Find potential and wavelength data from arrays
% get data array also removing padding 0 from potential array
potentials_array  = SEC_data_array(1,2:end);


%Find position of reference potential in array
c = ismember(potentials_array, baseline_potential);
indexes = find(c);

Ref_potential_check=potentials_array(c);

% get regerance array using logical indexing 
Ref_array=data(:,c);
R_ref=(Ref_array-data_0R)./data_100R_Zeroed;
FR_Ref=((1-R_ref).^2)./(2*R_ref);
R_test=(data(:,end)-data_0R)./data_100R_Zeroed;
FR_test=((1-R_test).^2)./(2*R_test);
DeltaFR_test=FR_test-FR_Ref;
DeltaFR_test=smooth(DeltaFR_test,20,'sgolay',3);

%plot 
figure
plot(wavelengths_array,DeltaFR_test,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Test delta F(R)')
set(gca,'Fontsize',20);
xlim([350 1050]);
set(gca,'linew',3)
%calculate reflectance


n=size(data);
n=n(2);
for i=1:n
Reflectance(:,i)=(data(:,i)-data_0R)./data_100R_Zeroed;
FR(:,i)=((1.-Reflectance(:,i)).^2)./(2.*Reflectance(:,i));
Delta_FR(:,i)=FR(:,i)-FR_Ref;
Delta_FR_S(:,i)=smooth(Delta_FR(:,i),100,'sgolay',3);
end 


%Plot data
% get the data region that is more than the ref potential
output_data=Delta_FR(:,indexes:end);
output_dataS=Delta_FR_S(:,indexes:end);

output_wavelength=wavelengths_array;
%Plot data
columns = size(output_data);
columns = columns(2);
set(0,'DefaultAxesColorOrder',jet(columns))

plot(output_wavelength,output_data,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta F(R)')
set(gca,'Fontsize',20);
xlim([350 1050]);
set(gca,'linew',3);


figure
plot(output_wavelength,output_dataS,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta F(R)')
set(gca,'Fontsize',20);
xlim([350 1050]);
set(gca,'linew',3);
clear



