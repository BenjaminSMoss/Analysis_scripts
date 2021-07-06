%imput decay filename, adjust the name in order
filename(1)="550_Kinetic_PDtest-1.11OSP-SP";
filename(2)="550_Kinetic_PDtest-1.13OSP-SP";
filename(3)="550_Kinetic_PDtest-1.15OSP-SP";
filename(4)="550_Kinetic_PDtest-1.17OSP-SP";
filename(5)="550_Kinetic_PDtest-1.19OSP-SP";
filename(6)="550_Kinetic_PDtest-1.21OSP-SP";
filename(7)="550_Kinetic_PDtest-1.23OSP-SP";
filename(8)="550_Kinetic_PDtest-1.25OSP-SP";
%filename(9)="550_Kinetic_SMOOTHED_1M-PDtest-1.39OSP-SP";
%filename(9)="550_Kinetic_PDtest-1.33-1OSP-SP";
%filename(10)="550_Kinetic_SMOOTHED_PDtest-1.35-1OSP-SP";
%filename(11)=
%filename(12)=
N=8; %imput the totall amount of files
Potential=1.11:0.02:1.25; %imput the corresponding potential for the files
t_start_set=21.7; %imput the decay start time, note that not exactly 20s as setting,check data first
percentage=0.70; %imput select percentage of calculation

for i=1:N  %for loop to get evry file input
    file=strcat(filename(i),'.csv');
    Data=csvread(file);
    time_array=Data(:,1);
    Delta_OD=Data(:,2); %delete data before 10s
    Delta_OD=Delta_OD./max(Delta_OD); %normalize signal to 1


    %find the decay start point
    Delta_t=abs(time_array-t_start_set);
    [Delta_t_min,t_min_index]=min(Delta_t);
    t_start_real=time_array(t_min_index);
    Delta_OD_start=Delta_OD(t_min_index);
    
 %find the select calculate point, according to the set percentage
 %the same percentage has two points, we peak the decay period point
decay_index=(time_array>=t_start_real);
time_array_decay=time_array(decay_index);
Delta_OD_decay=Delta_OD(decay_index);
Delta_OD_cal_set=percentage*Delta_OD_start;
Delta=abs(Delta_OD_decay-Delta_OD_cal_set);
[Delta_min,OD_min_index]=min(Delta);
Delta_OD_cal_real=Delta_OD_decay(OD_min_index);
t_cal=time_array_decay(OD_min_index);

    %Calculate time constant by normalize signal decay divide decay time period
    time_constant(i)=(t_cal-t_start_real)/(Delta_OD_start-Delta_OD_cal_real);
end

%plot potential vs time constant
figure
scatter(Potential,time_constant,'k','linewidth',0.5,'markerfacecolor',[36, 169, 225]/255)
xlabel('Potential (V vs Ag/AgCl)')
ylabel('Time constant(s)')
set(gca,'linewidth',1.1,'Fontsize',16,'fontname','times');
box on;
%ylim([0 1]);

% Write data
Final=[Potential',time_constant'];
percentage=percentage*100; %0.9 cannot set as a file name
fileN=sprintf("raw_percentage_%d_time_constant.csv",percentage);
csvwrite(fileN,Final);
