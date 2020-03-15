%% This is to select the climate data within the study period
% load gaps filled data

%% Summer Precipitation
% precipitation uses the data from TRS

clearvars
load('TarfalaAWS.mat');
fprintf('Tarfala AWS precipitation starts from %s to %s\n', timeTarfala(1),...
    timeTarfala(end));
t1 = datetime('01-Apr-2008 00:00:00');
t2 = datetime('01-Jul-2018 00:00:00');
[prec, time] = timeSelection(precTRS, timeTarfala, t1, t2);
save('climate.mat','prec','time');
figure;
subplot(4,1,1)
plot(time, prec);
title('precipitation');

%% temperature
clearvars
% temperature prior to AWS is selected from TRS ans SMHI
load('TarfalaAWS.mat');     
load('SMHI\SMHIAWS.mat');
TRSloc = location;

fprintf('Tarfala AWS temperature starts from %s to %s\n', timeTarfala(1),...
    timeTarfala(end));
fprintf('SMHI temperature starts from %s to %s\n', timeSMHItemp(1),...
    timeSMHItemp(end));

t1 = datetime('01-Apr-2008 00:00:00');
t2 = datetime('07-Jan-2009 16:00:00');
[temp1, time1] = timeSelection(tempTRS, timeTarfala, t1, t2);

t1 = t2 + hours(1);
t2 = datetime('03-Mar-2009 11:00:00') - hours(1);
[temp2, time2] = timeSelection(tempSMHI, timeSMHItemp, t1, t2);

t1 = t2 + hours(1);
t2 = datetime('17-Apr-2013 16:00:00') - hours(1);
[temp3, time3] = timeSelection(tempTRS, timeTarfala, t1, t2);

% when Ablation AWS operates
load('AblationAWS.mat');
AWSloc = location;
fprintf('Ablation AWS temperature starts from %s to %s\n', timeAWS(1), timeAWS(end));
t1 = datetime('17-Apr-2013 16:00:00');
t2 = datetime('01-Jul-2018 00:00:00');
[temp4, time4] = timeSelection(tempAWS, timeAWS, t1, t2);
tempLapse = (location.Z - TRSloc.Z)/100 * 0.6;

time = [time1; time2; time3; time4];
temp = [temp1-tempLapse; temp2-tempLapse; temp3-tempLapse; temp4];

subplot(4,1,2);
plot(time, temp);
title('temperature');

% temperature lapse rate
t1 = time(1);   t2 = time(end);
[tempLowZ, timeLowZ] = timeSelection(tempTRS, timeTarfala, t1, t2);
[y,m,d] = ymd(time);
G = findgroups(y);
tempTRSave = splitapply(@mean,tempLowZ,G);
tempAWSave = splitapply(@mean,temp,G);
tempDiff = tempAWSave - tempTRSave;
dZ = AWSloc.Z - TRSloc.Z;
tempLapse = tempDiff/dZ;
tempLapse(2) = -0.006;
yave = splitapply(@mean,y,G);
dT = [yave,tempLapse];
dTunit = 'C/m';

save('climate.mat','temp','dT','dTunit','TRSloc','AWSloc','-append');
%% RH
clearvars
load('TarfalaAWS.mat');

t1 = datetime('01-Apr-2008 00:00:00');
t2 = datetime('30-Jan-2009 11:00:00');
[rh1, time1] = timeSelection(RHTRS, timeTarfala, t1, t2);

load('SMHI\SMHIAWS.mat');
t1 = t2 + hours(1);
t2 = datetime('27-Mar-2009 10:00:00');
[rh2, time2] = timeSelection(rhSMHI, timeSMHIrh, t1, t2);

t1 = t2 + hours(1);
t2 = datetime('17-Apr-2013 15:00:00');
[rh3, time3] = timeSelection(RHTRS, timeTarfala, t1, t2);

load('AblationAWS.mat');
t1 = t2 + hours(1);
t2 = datetime('22-Jan-2015 12:00:00');
[rh4, time4] = timeSelection(RHAWS, timeAWS, t1, t2);

t1 = t2 + hours(1);
t2 = datetime('27-Apr-2015 14:00:00');
[rh5, time5] = timeSelection(rhSMHI, timeSMHIrh, t1, t2);

t1 = t2 + hours(1);
t2 = datetime('08-Sep-2015 11:00:00');
[rh6, time6] = timeSelection(RHAWS, timeAWS, t1, t2);

t1 = t2 + hours(1);
t2 = datetime('22-Sep-2015 14:00:00');
[rh7, time7] = timeSelection(rhSMHI, timeSMHIrh, t1, t2);

t1 = t2 + hours(1);
t2 = datetime('01-Jul-2018 00:00:00');
[rh8, time8] = timeSelection(RHAWS, timeAWS, t1, t2);

time = [time1; time2; time3; time4; time5; time6; time7; time8];
rh = [rh1; rh2; rh3; rh4; rh5; rh6; rh7; rh8];
save('climate.mat','rh','-append');

subplot(4,1,3);
plot(time, rh);
title('rh');

%% cloud
clearvars
load('SMHICloud.mat');
t1 = datetime('01-Apr-2008 00:00:00');
t2 = datetime('01-Jul-2018 00:00:00');
[cloud, time] = timeSelection(cloudNikk, timeNikk, t1, t2);
save('climate.mat','cloud','-append');
subplot(4,1,4);
plot(time, cloud);
title('cloud');

%% output
clearvars
load('climate.mat');
climate.cloud = cloud;
climate.prec = prec;
climate.dT = dT;
climate.dTunit = dTunit;
climate.temp = temp;
climate.AWSloc = AWSloc;
climate.TRSloc = TRSloc;
climate.rh = rh;
climate.time = time;
save('D:\data\code\testFSN\climate\Tarfala\climate.mat','climate');

