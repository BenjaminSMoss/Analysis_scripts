clc

% before using get your data into a .mat format with E as X, theta as Y
load('PB_J.mat')


fit_upper_k=10000;
fit_lower_k=1E-8;
fit_upper_a=1;
fit_lower_a=0;

theta=data(:,1);
j_exp=data(:,2);


[xData, yData] = prepareCurveData( theta, j_exp);
%+0.0256*log(t/(1-t))+(b/96485)*t+U1
% Set up fittype and options.
% set values in equation to the ones from frumkin fit - 
ft = fittype( 't*k*exp((-a*(t)+c))', 'independent', 't', 'dependent', 'E' );
%excludedPoints = (xData < exclude_lower) | (xData > exclude_upper);
%the above cuts the potential region where there might be noise in coverage
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.2769 -0.02 0.1];
%, 0.7, 1.55
opts.Lower = [  -inf -inf 1E-6];
%opts.Upper = [fit_upper_k  fit_upper_a ];

%opts.Exclude = excludedPoints;


% Fit model to data.
[fittedmodel, fitresult, gof] = fit( xData, yData, ft, opts );

% get parameters - convert the units of 'a' from J/mol to eV
k_new=fittedmodel.k;
disp('k0 value is (units of Amps if input is J)');
disp(k_new);
a_new=fittedmodel.a;
disp('a value is (dimensionless)');
disp(a_new);
c_new=fittedmodel.c;
disp('c value is (dimensionless)');
disp(c_new);
R_sq=fitresult.rsquare;
disp('Rsq value is');
disp(R_sq);
values_frumkin=[k_new,a_new,R_sq];


% get data
%First create a synthetic theta dataset covering the whole range
theta_synth=(0:0.01:01)';
J_fit_frumkin=fittedmodel(theta_synth);



plot(theta,j_exp, 'color', 'red', 'LineWidth',4)

hold on
plot(theta_synth, J_fit_frumkin, '--',  'color', 'blue','LineWidth',4) 

hold off
%put together, write`

data_orig=[theta,j_exp];

Data_final=[theta_synth,J_fit_frumkin];
Values_final=[values_frumkin];
writematrix(data_orig, 'experiment_data_J.csv')
writematrix(Data_final, 'Fitdata_J.csv')
writematrix(Values_final, 'Fitvalues_J.csv')
clear
