
clc;
clear all;

filename1='0.34-0.37.txt';
filename2='0.34-0.40.txt';
filename3='0.34-0.43.txt';
filename4='0.34-0.46.txt';
filename5='0.34-0.49.txt';
filename6='0.34-0.52.txt';
filename7='0.34-0.55.txt';
%filename8='1.20-1.39.txt';
%filename9='1.16-1.25-vmp3.txt';
%filename10='1.16-1.27-vmp3.txt';
N=7; % input number of files above

%choose data range, avoid data point (such as start and end region) that can affect the analysis
start=50;
final=650; % data size you want to plot (check size of original data to make sure all the data have the same size and can be written in one excel)
format long;
J_t_new=[];
max_charge_array=[];

for i=1:N
    i=num2str(i)
    filename=eval(strcat('filename',i));
    data=readmatrix(filename);
   time_array=data(start:final,1);
J_array=data(start:final,2);
%get the lowest J value as transit point
J_min=min(J_array);
min_index=J_array==J_min;
%set one data point before lowest point as t '0'
min_index_shift=[min_index(2:end)',logical([0])];
t_min=time_array(min_index_shift);
time_array_new=time_array-t_min;

%record J_t array for figure 
J_t_new=[J_t_new,time_array_new,J_array];

figure(1)
hold on
plot(time_array_new,J_array,'linewidth',1);
xlabel('Time (s)') 
ylabel('Current (A)')
set(gca,'Fontsize',18);
set(gca,'linew',1.5);

hold off
%charge intergrate
t_inter_index=time_array_new>=0;
t_inter=time_array_new(t_inter_index);
J_inter=J_array(t_inter_index);

%Intergrate, mind the negative and positive current point
charge=cumtrapz(t_inter,abs(J_inter-J_inter(end)));

%record max-charge array for figure 
max_charge_array=[max_charge_array,max(abs(charge))];

figure(2)
hold on
plot(t_inter,charge);
end
hold off
electron_num_array=(max_charge_array./1.6e-19)'

csvwrite(strcat(filename1(1:7),'_Jt_array.csv'),J_t_new);
csvwrite(strcat(filename1(1:7),'_electron_number.csv'),electron_num_array)

