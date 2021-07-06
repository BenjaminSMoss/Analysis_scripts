%Enter the value of t(0) 
t_val = 1;
filename1='PDtest-1.33OSP-SP';
filename=strcat(filename1,'.csv');
%Enter the filename for the SEC data
SEC_data_array  = csvread(filename);

%Find potential and wavelength data from arrays
% get data array also removing padding 0 from potential array
time_array  = SEC_data_array(1,2:end);
wavelengths_array = SEC_data_array(:,1);
data_array= SEC_data_array(2:end,2:end);

%Find position of reference time in array
Delta_t=abs(time_array-t_val);
t_valmin=min(Delta_t);
time_TF=Delta_t==t_valmin;
t_val2=time_array(time_TF);

c = ismember(time_array, t_val2);
indexes = find(c);
time_array2=time_array(indexes:end)';


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

for i=1:N
    
   DOD_smooth(:,i)=smooth(DOD(:,i),500,'sgolay',3);
end 
% get the data region that is more than the ref potential
output_data=DOD(:,indexes:end);
output_dataS=DOD_smooth(:,indexes:end);
% remove leading zero from WL array
output_wavelength=wavelengths_array(2:end);
%Plot data
columns = size(output_dataS);
columns = columns(2);
set(0,'DefaultAxesColorOrder',jet(columns))

plot(output_wavelength,output_dataS,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
title('Smoothed spectra')
set(gca,'Fontsize',20);
xlim([350 1050]);
set(gca,'linew',3);
    
figure
surface(time_array2,output_wavelength,output_dataS,'EdgeColor','none');
xlabel('Time (s)', 'FontSize', 25)

ylabel('Wavelength (nm)', 'FontSize', 25)
colorbar()
%h = colorbar();
%ylabel(h,'ΔA','FontSize', 16)
%set(h, 'ylim', [-100E-6,3E-3])
colormap turbo
set(gcf,'color','w');
set(gca,'FontSize',20)

%title('SEC data summary')
% put it all together
WL = SEC_data_array(:,1);
Final=[time_array;DOD];
Final=[WL,Final];

FinalS=[time_array;DOD_smooth];
FinalS=[WL,FinalS];

fileN=strcat(filename1,'_DOD.csv');
fileN2=strcat(filename1,'_SMOOTH_','DOD.csv');
csvwrite(fileN,Final);
csvwrite(fileN2,FinalS);
clear
%clc
