%% winter precipitation estimation
%% snow water equivalent

clearvars
load('DEM.mat');
snowpath = 'sg_mb_output\snow\';
denspath = 'sg_mb_output\density\';
meltpath = 'sg_mb_output\melt\';
subsnow = dir(snowpath);
subdens = dir(denspath);
submelt = dir(meltpath);
for i = 3:length(subsnow)
    load([snowpath,subsnow(i).name]);
    load([denspath,subdens(i).name]);
    load([meltpath,submelt(i).name]);
    snowGrid = griddata(snow.X,snow.Y,snow.snow,DEM.X,DEM.Y,'v4');
    k = table2array(density.mdl.Coefficients(2,1));
    b = table2array(density.mdl.Coefficients(1,1));
    water.water = (k * snowGrid + b) * 10;
%     densityGrid = griddata(density.Xa,density.Ya,density.densityAve,...
%         DEM.X,DEM.Y,'v4');
%     water.water = densityGrid.*snowGrid*10;
    water.water = interp2(water.water,-5,'linear');
    water.unit = 'mm w.e.';
    water.X = snow.X;   water.Y = snow.Y;
    water.year = snow.year;
    disp(water.year);
    meltGrid = griddata(melt.X,melt.Y,melt.melt,DEM.X,DEM.Y,'v4');
    meltDepth = meltGrid - snowGrid;
%     abl.melt = ones(size(meltDepth));
%     abl.melt(meltDepth <= 0) = k * (meltDepth(meltDepth <= 0)) + b;
%     abl.melt(meltDepth >  0) = water.water(meltDepth >  0) + 0.9 * (snowGrid
    abl.melt = meltGrid*100;
    abl.melt = interp2(abl.melt,-5,'linear');
    abl.X = melt.X;     abl.Y = melt.Y;
    abl.year = melt.year;
    abl.unit = 'm';
    save(['sg_mb_output\water\',subsnow(i).name(1:end-4),'.mat'],'water',...
        'snowGrid','abl');
    figure;
    title(water.year);
    subplot(3,1,1);
    imagesc(snowGrid);  colorbar;
    title('snow');
    subplot(3,1,2);
    imagesc(abl.melt);   colorbar;
    title('melt');
    subplot(3,1,3);
    imagesc(water.water);   colorbar;
    title('mm w.e.');
end

%% generate of time series winter snowfall
clearvars
% delete 'sg_mb_output\solid\solidprec.csv'
load('DEM.mat');
waterpath = 'sg_mb_output\water\';
subdir = dir(waterpath);
solid.snow = [];    solid.time = [];
for i = 4:length(subdir)% from 2009 winter to 2018
    load([waterpath,subdir(i).name]);
    t2 = datetime(water.year  , 05,01,00,00,00);
    t1 = datetime(water.year-1, 10,01,00,00,00);
    time = (datetime(t1):hours(3):datetime(t2))';
    step = numel(time);
    snow = ones(size(water.water));
    snow = repmat(snow,[1 1 step]);
    for m = 1:step
        snow(:,:,m) = water.water/step.*snow(:,:,m);
        disp(time(m));
    end
    solid.snow = cat(3,solid.snow,snow);
    solid.time = cat(1,solid.time,time);
end
save('sg_mb_output\solid.mat','solid');
%% CTS
% % CHECK THE COORDINATES!!!
% clearvars
% rawdata = xlsread('CTS.xls');
% [CTS.Y, CTS.X] = SWEREF2WGS84('sweref_99_2015', rawdata(:,2), rawdata(:,1));
% CTS.Z = rawdata(:,3);
% load('DEM.mat');
% map = griddata(CTS.X, CTS.Y, CTS.Z, DEM.X, DEM.Y, 'V4');
% % CTS.map = interp2(map,-5,'linear');
% % CTS.year = 2008;
% % save('sg_mb_output\CTS.mat','CTS');


