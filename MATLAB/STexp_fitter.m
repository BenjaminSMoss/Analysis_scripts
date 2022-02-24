%********************************************************************%
%load('CoOOH_PD_decay_norm')
name0='caiwu';
%data=PD_0p96;
t=data(:,1);
t=t-t(1);
dec=data(:,2);


%Linear fitting of selected region
%define linear equation
mod1 = @(b,x)(b(1))*(exp(-(x.^(b(2)))))+b(3);
% define starting beta values - b1 is grad, b2 is intercept
beta=[1,0.5,0.1];
%fit
betaMod=lsqcurvefit(mod1,beta,t,dec);
%get data from fit
decay_mod=mod1(betaMod,t);

%plot
plot(t,dec,'LineWidth',3); hold on

%plot
plot(t,decay_mod,'LineWidth',3); hold off
legend('data','fitted data')
xlabel('Time (s)')
ylabel('Norm.O.D')
ylim([0 0.9])
xlim([0 50])
title(name0)
set(gcf,'color','w');
%end
% create text file
final=[t,dec,decay_mod];
name1=strcat(name0,'_fit_','.csv');
name2=strcat(name0,'_beta_','.csv');
csvwrite(name1,final)
csvwrite(name2,betaMod)
%clear
