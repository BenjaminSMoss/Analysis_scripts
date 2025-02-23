clc
%imput SEC_DOD data with iR correction 
filename1='test-2SEC1.224VsmoothDOD_iR';
filename=strcat(filename1,'.csv');
Data=csvread(filename);

% set the potential window
upper=1.7063;
lower=0.96499;
interval=0.02;
Potential_array=Data(1,2:end);
Wavelength_array=Data(:,1);
% choose intervals you wanna plot 
Potential_get=lower:interval:upper;
N=length(Potential_get);
Potential_get_index=[];

%find potntial that most close to each point in intervals
for i=1:N
delta=abs(Potential_array-Potential_get(i));
[value,index]=min(delta);
Potential_get_index=[Potential_get_index,index];
end
%exctrat the array according to the interval
Extract_array=Data(:,(Potential_get_index+1));
Extract_array=[Wavelength_array,Extract_array];

%plot figue
columns = size(Extract_array(2:end,2:end));
columns = columns(2);
set(0,'DefaultAxesColorOrder',jet(columns))
plot(Extract_array(2:end,1),Extract_array(2:end,2:end),'linewidth',1);
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',20);
set(gca,'linew',3);
set(gcf,'color','w');
axis square
figure
plot(Extract_array(2:end,1),Extract_array(2:end,2:end),'linewidth',1)
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',16);
set(gca,'linew',3);
%xlim([WL_min+50 WL_max-50]);
leg=num2str(Extract_array(1,2:end));
legend(leg);
lgd.FontSize = 12;
lgnd.BoxFace.ColorType='truecoloralpha';
lgnd.BoxFace.ColorData=uint8(255*[1 1 1 0.75]');
set(gcf,'color','w');
axis square

%save data
intervalName=num2str(interval);
fileN=strcat(filename1,'_interval_', intervalName,'V_increment.csv');
csvwrite(fileN,Extract_array);

clear
