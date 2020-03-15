%% initial conditions
% Tinit: temp depth
% Dinit: density depth
%% Dinit
clearvars
load('E:\data\Tarfala\glacier\sg_mb_output\snow\sg_snow_2009.mat');
load('E:\data\Tarfala\glacier\sg_mb_output\density\sg_dens_2009.mat')

numDens = unique(density.ID);
figure;
for i = 1 : numel(numDens)
    index = density.ID == numDens(i);
    hold on
    plot(density.density(index), density.depth(index),'DisplayName', num2str(i));
    hold off
end
set(gca, 'YDir','reverse')
title('dens vs depth'); legend;
figure;
for i = 1 : numel(numDens)
    index = density.ID == numDens(i);
    hold on
    plot(density.density(index), log(density.depth(index)),'DisplayName', num2str(i));
    hold off
end
set(gca, 'YDir','reverse')
title('log dens'); legend;

% conclusion is dens vs depth is log linear

mdl = fitlm(log(density.depth), density.density,'RobustOpts','on',...
    'VarNames',{'depth','density'});
disp(mdl);
figure;
plot(mdl);
xlabel('depth log-cm');     ylabel('density g cm^-^3');

k = table2array(mdl.Coefficients(2,1));
b = table2array(mdl.Coefficients(1,1));

load('DEM\DEM.mat');
depthSnow = griddata(snow.X,snow.Y,snow.snow,DEM.X,DEM.Y,'v4');
figure;
plot3(snow.X,snow.Y,snow.snow,'ro')
hold on
surface(DEM.X,DEM.Y,depthSnow);
title('spatial interpolation of snow depth');
shading flat;

depthSnow = interp2(depthSnow,-5,'linear');
clearvars DEM storDEM

load('DEM\DEMstor.mat');
mask = reshape(DEM.Blank,[],1);
index = isnan(mask);
depthSnow = reshape(depthSnow,[],1);
depthSnow(index) = [];

depth = (1:60) * 100;
depth = repmat(depth, numel(depthSnow),1);
Dinit = ones(size(depth))*0.9;

numGrid = nansum(mask);
for i = 1 : numGrid
    if depth(i,1) > depthSnow(i)
        depthSnow(i) = depth(i,1); % if snow layer < 1m then set it as 1m
    end
    snowLayer = 100:100:depthSnow(i);
    Dinit(i,1:length(snowLayer)) = k*log(snowLayer) + b;
end
Dinit = Dinit * 1000;
save('reboot\spatialInit.mat', 'Dinit');

%% Tinit
clearvars Dinit
load('reboot\surfTinit.mat');
load('DEM\CTS.mat');
cts = reshape(CTS.map*100, [], 1);
cts(index) = [];

Tinit = zeros(size(depth));
for i = 1 : numGrid
    if cts(i) < 0
        CTSdepth = 10;
    else
    CTSdepth = round(cts(i)/100);
%     CTSdepth = 10;
    end
%     iceLayer = 100:100:depthSnow(i);
    Tinit(i,1:CTSdepth) = linspace(surfTinit(i), 0, CTSdepth);
end

save('reboot\spatialInit.mat', 'Tinit', '-append');