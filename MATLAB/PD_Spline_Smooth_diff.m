%input data
clc
filename='500_Kinetic_PD-0.427-0.527OSP-SP';
filename1=strcat(filename,'.csv');
Data=readtable(filename1);
Data=table2array(Data);

% params to change
fit_tolerance_fast= 7e-7; % smoothing strength - more is stronger
fit_tolerance_slow= 3e-6;
decay_start_time=51.3;
slowerdecay_time=80;


%select data range
x=Data(:,1); 
y1=Data(:,2);


%collect decay region
x_decTF=x>=decay_start_time & x<=slowerdecay_time;
x_decTF_late=x>slowerdecay_time;

 x_dec=x(x_decTF,:);
  y_dec=y1(x_decTF,:);

  x_late=x(x_decTF_late);
  y_late=y1(x_decTF_late);
  % compare decay region and 
figure(1)
plot(x,y1,'-', x_dec,y_dec)

%zero X_dec
x_dec=x_dec-min(x_dec);

%set fitting tolerance, the less the best fitting for original data, but
%more noisy for differential data

% Specify the smoothing parameter p that vary across the data.
p=fit_tolerance_fast*[ones(1,560),0.001*ones(1,75),ones(1,465)];
[sp1,y1_fit] = spaps(x_dec,y_dec,fit_tolerance_fast);

figure(2)
y1_fit=fnplt(sp1);
y1_fit=y1_fit';
plot(x_dec,y_dec,'-',y1_fit(:,1),y1_fit(:,2));
xlim([-0.5 max(x_dec)])

figure(3);
fnplt(fnder(sp1));
ydiff_fit=fnplt(fnder(sp1))';
xlim([-0.5 max(x_dec)])




fileN=strcat(filename,'_SPLINE.csv');
fileN1=strcat(filename,'_DIFF_SPLINE.csv');
csvwrite(fileN,y1_fit);
csvwrite(fileN1,ydiff_fit);


clear