%% spatial distributed climatic input over the whole glacier
% varStor: regrided data


%% Spatially distributed temperature
clearvars
load('climate\Tarfala\climate.mat');
climate.temp = movmean(climate.temp, [2 0]);
load('DEM\DEM.mat');
tempDEM = DEM.Z - climate.AWSloc.Z;
tempGrad = tempDEM * mean(climate.dT(:,2));
tempGrad = interp2(tempGrad,-5,'linear');
numData = numel(tempGrad);
tempStor = ones(size(climate.temp));
tempStor = repmat(tempStor, [1 1 numData]);
for i = 1:numData
    tempStor(:,:,i) = tempGrad(i) + climate.temp;
    fprintf('tempStor grid %d out of %d\n', i, numData);
end
% extract every 3 hours instead of 1hour
tempStor = tempStor(1:3:size(tempStor,1),1,:);
% d3: different grid points
% d1: time series tem
save('DEM\climateStor.mat','tempStor');

%% precipitation
% winter precipitation

clearvars 
load('climate\Tarfala\climate.mat');
climate.prec = movsum(climate.prec, [2 0]);
load('DEM\DEM.mat');
load('DEM\solid.mat');
solid.snow = reshape(solid.snow,[],1,numel(solid.time));    

storGrid = interp2(DEM.X,-5,'linear');
clear DEM storDEM
numData = numel(storGrid);
precStor = ones(size(climate.time));
precStor = repmat(precStor, [1 1 numData]);
time = climate.time;
% time = repmat(time, [1 1 numData]);
for i = 1:numData
    precStor(:,:,i) = precStor(:,:,i).*climate.prec;
    index = ismember(time, solid.time);
    snow = solid.snow(i,:,:); 
    snow = reshape(snow,[],1);
    precStor(index,:,i) = precStor(index,:,i) + snow;
    fprintf('precStor grid %d out of %d\n', i, numData);
end
% extract every 3 hours instead of 1hour
precStor = precStor(1:3:size(precStor,1),1,:);
time = time(1:3:length(time), 1);

save('DEM\climateStor.mat','precStor','time','-append');

%% RH cloud
clearvars -except climate numData
climate.rh = movmean(climate.rh, [2 0]);

RHStor = repmat(climate.rh, [1 1 numData]);
% extract every 3 hours instead of 1hour
RHStor = RHStor(1:3:size(RHStor,1),1,:);

cloud = climate.cloud/100;
cloud(cloud>1) = 1;
cloud = movmean(cloud, [2 0]);
cloudStor = repmat(cloud, [1 1 numData]);
% extract every 3 hours instead of 1hour
cloudStor = cloudStor(1:3:size(cloudStor,1),1,:);

save('DEM\climateStor.mat','RHStor','cloudStor','-append');

%% DEMStor
clearvars
load('DEM\DEM.mat');
DEM.X = interp2(DEM.X,-5,'linear');
DEM.Y = interp2(DEM.Y,-5,'linear');
DEM.Z = interp2(DEM.Z,-5,'linear');
DEM.Outline = DEM.Outline;
DEM.Blank = interp2(DEM.Blank,-5,'linear');
save('DEM\DEMstor.mat','DEM','storDEM');
%% final output
clearvars
load('DEM\DEMStor.mat');
load('DEM\climateStor.mat');
% [yr,mo,da] = ymd(time);
% [hr,mi,se] = hms(time);
% date = [yr mo da hr mi se];
date = datenum(repmat(time, [1 1 size(precStor,3)]));
output = [date tempStor RHStor cloudStor precStor];
mask = reshape(DEM.Blank,[],1);
index = isnan(mask);
output(:,:,index) = [];
save('climate\Tarfala\spatial\climateStor.mat','output','-v7.3');
surfTinit = squeeze(output(2921,2,:));
save('reboot\surfTinit.mat','surfTinit');