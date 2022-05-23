%input data
clc
filename='500_Kinetic_PD-0.427-0.477OSP-SP';
filename1=strcat(filename,'.csv');
Data=readtable(filename1);
Data=table2array(Data);

% params to change
fit_tolerance_fast= 25e-7; % smoothing strength - more is stronger
fit_tolerance_slow=22e-7;
decay_start_time=51.5;
slowerdecay_time=decay_start_time+100;


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
title 'region selected for early decay'
xlim([decay_start_time-5 decay_start_time+25])

%zero X_dec
zero_val=min(x_dec);
x_dec=x_dec-zero_val;
%zero x_late
x_late=x_late-zero_val;
%set fitting tolerance, the less the best fitting for original data, but
%more noisy for differential data

% Specify the smoothing parameter p that vary across the data.
p=fit_tolerance_fast*[ones(1,560),0.001*ones(1,75),ones(1,465)];
[sp1,y1_fit] = spaps(x_dec,y_dec,fit_tolerance_fast);
[sp2,y2_fit] = spaps(x_late,y_late,fit_tolerance_slow);

figure(2)
y1_fit=fnplt(sp1);
y1_fit=y1_fit';
plot(x_dec,y_dec,'-',y1_fit(:,1),y1_fit(:,2));
xlim([-0.5 max(x_dec)])
title 'comparison of data to smooth at early times'

figure(3)
y2_fit=fnplt(sp2);
y2_fit=y2_fit';
plot(x_late,y_late,'-',y2_fit(:,1),y2_fit(:,2));
xlim([max(x_dec) max(x_late)])
title 'comparison of data to smooth at late times'

figure(4);
fnplt(fnder(sp1));
ydiff_fit=fnplt(fnder(sp1))';
xlim([-0.5 max(x_dec)])
title 'early time rate of decay'

figure(5);
fnplt(fnder(sp2));
ydiff_fit_late=fnplt(fnder(sp2))';
%xlim([max(x_dec) max(x_late)])
title 'late time rate of decay'

y_fit_all=[y1_fit;y2_fit];
Y_diff_all=[ydiff_fit;ydiff_fit_late];


figure(5);
plot(Y_diff_all(:,1),Y_diff_all(:,2))
%xlim([max(x_dec) max(x_late)])
title ' rate of decay, stiched '

fileN=strcat(filename,'_SPLINE.csv');
fileN1=strcat(filename,'_DIFF_SPLINE.csv');
csvwrite(fileN,y_fit_all);
csvwrite(fileN1,Y_diff_all);


%clear