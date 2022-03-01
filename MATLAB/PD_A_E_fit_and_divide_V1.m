%input data
clc
%get A kinetics
filename0='490_Kinetic_1p1OSP-SP';
filename1=strcat(filename0,'.csv');
Data_A=csvread(filename1);
% get E kinetics 
filename2='1p0OSP-E-t';
filename3=strcat(filename2,'.csv');
Data_E=csvread(filename3);

% get first time of E array. Shape A arrays acoordingly 

t_0=Data_E(1,1);
t_0_TF=Data_A(:,1)>=t_0;
Data_A=Data_A(t_0_TF,:);

%sep into two time arrays A and E array - zero times
t_A=Data_A(:,1);
t_A=t_A-min(t_A);
A=Data_A(:,2);
t_E=Data_E(:,1);
t_E=t_E-min(t_E);
E=Data_E(:,2);

%make a synthetic array for input of time
t_synth=[t_E(1):0.03:t_E(end)]';
%quick plot 
figure(1)
yyaxis left
plot(t_A,A)
yyaxis right
plot(t_E,E)
title('comparison of A and E')

%see function definition at bottom of script
%this function takes in data, spline fits and then interpolates with the
%synthetic x array given. X array should be of same precision as orininal x
%array
[t_synth_check,A_fit,gof1]=Spline_Fitter(t_A,t_synth,A);

figure(2)
plot(t_synth_check,A_fit)
hold on
plot(t_A,A)
title('fitted and raw absorbance')
hold off


[t_synth_check,E_fit,gof2]=Spline_Fitter(t_E,t_synth,E);


figure(3)
plot(t_synth_check,E_fit)
hold on
plot(t_E,E)
title('fitted and raw potetial')
hold off

final_array=[t_synth_check, A_fit, E_fit];
final_name=strcat(filename0,'INTERPOLATE.csv');
writematrix(final_array,final_name)

clear

function  [x_synth,Y_fit,gof] = Spline_Fitter(x_orig,x_synth,y)


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData(x_orig, y);

% Set up fittype and options.
ft = fittype( 'smoothingspline' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );
 Y_fit=fitresult(x_synth);
end
