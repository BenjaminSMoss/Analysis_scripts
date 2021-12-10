%imput decay file at certain potential,get time array, wavelength array and spectra 
filename1='2h2-PD-1p88OSP-SP';
filename=strcat(filename1,'.csv');
data=csvread(filename);
time_array=data(1,2:end);
spectra=data(2:end,2:end);
filename2='WL';
filename2_=strcat(filename2,'.csv');
WL_array = csvread(filename2_);

% set a range for wavelength average,a certain point of wavelength cannot get good data quality due to the noise
range=10;
%create initial virable for data saving during for loop 
DataDOD=0; 
Wavelength=0;
DataDODS=0;
WavelengthS=0;
%choose a time before signal increase as background adsorption 
t_reference=20;
%set the time of decay start point.
t_start_set=40;
%set after how long from the decay start we calculate the signal decay
decay_time=80;
%obtain decay spectra at every wavelength
for WL_val=450:0.5:800
upper=WL_val+range;
lower=WL_val-range;
% get the index of of the choosen region
wavelength_index=WL_array<upper&WL_array>lower;
%get t value and its index closest to selected time using min fuction
Delta_t=abs(time_array-t_reference);
[t_reference_min,t_reference_index]=min(Delta_t);
%get spectra of the choosen region
region_spectra=spectra(wavelength_index,:);
% get mean spectra value of the choosen region 
Final=mean(region_spectra);

% substracting the signal at the reference time,create decay plotter
Io=Final(t_reference_index);
DOD=-log10(Final/Io);
DOD_smooth=smooth(DOD,50,'sgolay',3);

%calculate the signal decay from the start time to the choose time.
  %first find the decay start point
    Delta_t=abs(time_array-t_start_set);
    [Delta_t_min,t_min_index]=min(Delta_t);
    t_start_real=time_array(t_min_index);
    Delta_OD_start=DOD(t_min_index);  
    Delta_OD_start_smooth=DOD_smooth(t_min_index);
%then find the select calculate point, according to the set time after start
    Delta_t_decay=abs(time_array-(t_start_set+decay_time));
    [Delta_t_cal_min,t_cal_index]=min(Delta_t_decay);
    t_cal=time_array(t_cal_index);
    Delta_OD_cal=DOD(t_cal_index);
    Delta_OD_cal_smooth=DOD_smooth(t_cal_index);
    
%calculate the signal change from the decay, both from raw data and smooth data    
DeltaDOD=Delta_OD_start- Delta_OD_cal;
DeltaDODS=Delta_OD_start_smooth-Delta_OD_cal_smooth;

%store results for every wavelength into a vector, note the new zero added 
DataDOD=[DataDOD,DeltaDOD];
Wavelength=[Wavelength,WL_val];

DataDODS=[DataDODS,DeltaDODS];
WavelengthS=[WavelengthS,WL_val];
end
%remove the initial zero in the vector
DataDOD=DataDOD(2:end);
DataDOD=DataDOD';
DataDODS=DataDODS(2:end);
DataDODS=DataDODS';
Wavelength=Wavelength(2:end);
Wavelength=Wavelength';
WavelengthS=WavelengthS(2:end);
WavelengthS=WavelengthS';
%Smooth DataDODS
%Smooth_DataDODS=smooth(DataDODS,80,'sgolay',3);


figure
plot(Wavelength,DataDOD);
xlabel('Wavelength (nm)')
ylabel('delta DOD')
set(gca,'Fontsize',16);
set(gca,'linew',1.1);
%ylim([0,0.005]);
xlim([450,850]);

figure
plot(WavelengthS,DataDODS,'color','blue');
xlabel('Wavelength (nm)')
ylabel('delta DOD')
set(gca,'Fontsize',16);
set(gca,'linew',1.1);
%ylim([0,0.005]);
xlim([450,850]);
%hold on
%plot(WavelengthS,Smooth_DataDODS,'color','red');
%xlabel('Wavelength (nm)')
%ylabel('m(delta DOD)')
%set(gca,'Fontsize',20);
%set(gca,'linew',3);
%hold off

% put data together to new file
Final=[Wavelength,DataDOD];
FinalS=[WavelengthS,DataDODS];
filename1=sprintf("Decay_derived_%ds_%s",decay_time,filename);

csvwrite(filename1,Final);
csvwrite(filename2,FinalS);
