clc

% before using get your data into a .mat format with E as X, theta as Y
load('PB_data.mat')

exclude_upper=0.98;
exclude_lower=0.2;
fit_upper_E0=3;
fit_lower_E0=0;
fit_upper_r=1;
fit_lower_r=0;

theta=data(:,2);
E_exp=data(:,1);

[xData, yData] = prepareCurveData( theta, E_exp);

% Set up fittype and options.
ft = fittype( '0.0256*log(t/(1-t))+(a/96485)*t+U0', 'independent', 't', 'dependent', 'E' );
excludedPoints = (xData < exclude_lower) | (xData > exclude_upper);
%the above cuts the potential region where there might be noise in coverage
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.7 0.1];
%opts.Lower = [ fit_lower_E0 fit_lower_r];
%opts.Upper = [fit_upper_E0  fit_upper_r ];

opts.Exclude = excludedPoints;


% Fit model to data.
[fittedmodel, fitresult, gof] = fit( xData, yData, ft, opts );



% get data
%First create a synthetic theta dataset covering the whole range
theta_synth=(0:0.01:1)';
E_fit_frumkin=fittedmodel(theta_synth);

% get parameters - convert the units of 'a' from J/mol to eV
a_new=fittedmodel.a;
a_new=(a_new/6.02E23)*6.242e+18;
values_frumkin=[fittedmodel.U0,a_new,fitresult.rsquare];


% Set up langmuir and options.
ft2 = fittype( '0.0256*log(t/(1-t))+U0', 'independent', 't', 'dependent', 'E' );
excludedPoints = (xData < exclude_lower) | (xData > exclude_upper);
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
%opts.Lower = fit_lower_E0;
%opts.Upper = fit_upper_E0;
opts.StartPoint = 1.5;
opts.Exclude = excludedPoints;


% Fit model to data.
[fittedmodel2, fitresult2, gof2] = fit( xData, yData, ft2, opts );

% get data
E_fit_langmuir=fittedmodel2(theta_synth);
values_langmuir=[fittedmodel2.U0,fitresult2.rsquare];


plot(E_exp,theta, 'color', 'red', 'LineWidth',4)

hold on
plot(E_fit_frumkin,theta_synth, '--',  'color', 'blue','LineWidth',4) 
hold on
plot(E_fit_langmuir,theta_synth, ':','color', 'green','LineWidth',4)
hold off
%put together, write
data_orig=[E_exp,theta];
Data_final=[E_fit_frumkin,theta_synth,E_fit_langmuir,theta_synth];
Values_final=[values_frumkin,values_langmuir];
writematrix(data_orig, 'experiment_data.csv')
writematrix(Data_final, 'Fitdata.csv')
writematrix(Values_final, 'Fitvalues.csv')
clear
