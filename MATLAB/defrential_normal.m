%input data
filename='2-SEC-0p5-1p6-0p01SEC1.11VDOD_iR_interval_25mVs'
filename1=strcat(filename,'.csv');
Data=readtable(filename1)
Data=table2array(Data)
%select data range
x=Data(:,1); 
y1=Data(:,2);
y2=Data(:,3);
y3=Data(:,4);

%set fitting tolerance, the less the best fitting for original data, but
%more noisy for differential data
fit_tolerance1= 8e-09
fit_tolerance2= 8e-09
fit_tolerance3= 9e-10
% Specify the smoothing parameter p that vary across the data.
p=fit_tolerance3*[ones(1,560),0.001*ones(1,75),ones(1,465)]

%x=x(1:end-250);  %delete noisy data at high potential
%y1=y1(1:end-250);
%y2=Data(:,3);
%y2=y2(1:end-250);
%y3=Data(:,4);
%y3=y3(670:end);

%estimate noise range and fitting 
%sqrt(estimatenoise(y1));

[sp1,y1_fit] = spaps(x,y1,fit_tolerance1);
fnplt(sp1)
y1_fit=fnplt(sp1)
y1_fit=y1_fit';

[sp2,y2_fit] = spaps(x,y2,fit_tolerance2);
fnplt(sp2)
y2_fit=fnplt(sp2)
y2_fit=y2_fit';

% choose another fitting method csaps for the linear line fitting, and control the smooth at different region.
[sp3,y3_fit] = spaps(x,y3,fit_tolerance3);
fnplt(sp3)
y3_fit=fnplt(sp3)
y3_fit=y3_fit';


%x_fit= 300:1:500 %choose the data arrange you need to get 
%y1_fit=feval(spl,x_fit)
%sqrt(estimatenoise(y2));
%sp2 = spaps(x,y2,2e-08);
%fnplt(sp2)


%sqrt(estimatenoise(y3));
%sp3 = spaps(x,y3,2e-08);
%fnplt(sp3)


figure (1)
plot(x,y1,'k.')
hold on
fnplt(sp1)
plot(x,y2,'k.')
fnplt(sp2)
plot(x,y3,'k.')
fnplt(sp3)
hold off
figure (2)
hold on
fnplt(fnder(sp1))
y1_fit_dif=fnplt(fnder(sp1))
y1_fit_dif=y1_fit_dif';
fnplt(fnder(sp2))
y2_fit_dif=fnplt(fnder(sp2))
y2_fit_dif=y2_fit_dif';
fnplt(fnder(sp3))
y3_fit_dif=fnplt(fnder(sp3))
y3_fit_dif=y3_fit_dif';
hold off
%figure (3)
%fnplt(fnder(fnder(spl),1))
%y1_fit_dif2=fnplt(fnder(fnder(spl),1))
%y1_fit_dif2=y1_fit_dif2'
y_fit=[y1_fit,y2_fit,y3_fit]
y_fit_dif=[y1_fit_dif,y2_fit_dif,y3_fit_dif]
fileN=strcat(filename,'_fit.csv');
fileN1=strcat(filename,'_fit_dif.csv');
%fileN2=strcat(filename,'_fit_dif2.csv');
csvwrite(fileN,y_fit);
csvwrite(fileN1,y_fit_dif);
%csvwrite(fileN2,y1_fit_dif2);
%hold on
%fnplt(fnder(sp2))
%fnplt(fnder(sp3))