filename1='test-1-finalOSP-SP';
filename=strcat(filename1,'.csv');
data=csvread(filename);

% set Wl and range to average around select referanc time to calculate DOD
WL_val=500;
range=0.05;
upper=WL_val+WL_val*range;
lower=WL_val-WL_val*range;
t_val=10;
% get data 
time=data(1,:);
WL=data(:,1);
spectra=data(2:end,2:end);

% get boolean for WL ranges
WL_TF=WL<upper&WL>lower;

%get t value closest to selected 


Delta_t=abs(time-t_val);
t_valmin=min(Delta_t);
time_TF=Delta_t==t_valmin;
t_val2=time(time_TF);



%get region of interest
region=spectra(WL_TF,:);

% average WL values together
N=length(time);
N=N-1;
for i=1:N
    Final(i)=mean(region(:,i));
end 
time2=time(2:end)';
time2=time2';

% get the intensity at selected time

time_TF2=time_TF(2:end)';
Io=Final(time_TF2);
DOD=-log(Final/Io);
%DOD_smooth=smooth(DOD,50,'sgolay',3);
% plot data region
figure
plot(time2,Final);

figure
hold on
plot(time2,DOD) 
%plot(time2,DOD_smooth,'color','red') 
hold off

Final=[time2',DOD'];
FinalS=[time2',DOD_smooth];

WL_val_string=num2str(WL_val);
filename2=strcat(WL_val_string,"_Kinetic_",filename);
filename_s=strcat(WL_val_string,"_Kinetic_SMOOTHED_",filename);

csvwrite(filename2,Final);
csvwrite(filename_s,FinalS);

clear
clc

