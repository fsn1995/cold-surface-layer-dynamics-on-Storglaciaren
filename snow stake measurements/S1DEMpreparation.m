clearvars
dempath = 'storglaciarenDEM\SLUDEM2m\DEM2M\hojd2m3006_7535210_646780.tif';
storpath = 'storglaciarenDEM\Storglaciaren\';
%% SLU DEM
% 
% outline = dlmread([storpath,'\rphelp\stor90_SWEREF_TM.bln'],',',1,0);
% xlim = [min(outline(:,1)) max(outline(:,2)) min(outline(:,1))];
% ylim = [min(outline(:,2)) min(outline(:,2)) max(outline(:,1))];
% % [outline(:,1), outline(:,2)] = SWEREF2WGS84('sweref_99_tm',outline(:,2), outline(:,1));
% [A,x,y,I] = geoimread(dempath,xlim,ylim);
% [X,Y] = meshgrid(x,y);
% [lat,lon] = SWEREF2WGS84('sweref_99_tm',Y,X);
% DEM.Y = lat;    DEM.X = lon;    DEM.Z = A;
% mask = inpolygon(lat,lon,outline(:,1), outline(:,2));
% DEM.Blank = ones(size(mask));
% DEM.Blank(~mask)=nan;
% DEM.Outline = outline;
[A,x,y,I] = geoimread(dempath);
[X,Y] = meshgrid(x,y);
[lat,lon] = SWEREF2WGS84('sweref_99_tm',Y,X);
DEM.Y = lat;    DEM.X = lon;    DEM.Z = A;  DEM.I = I;
outline = dlmread([storpath,'\rphelp\stor90_SWEREF_TM.bln'],',',1,0);
[outline(:,1), outline(:,2)] = SWEREF2WGS84('sweref_99_tm',outline(:,2), outline(:,1));
mask = inpolygon(lat,lon,outline(:,1), outline(:,2));
DEM.Blank = ones(size(mask));
DEM.Blank(~mask)=nan;
DEM.Outline = outline;
figure;
surfc(DEM.X, DEM.Y, DEM.Z);
% % Remove rows and cols with all nans
% nancol = find(all(isnan(DEM.Blank),1));
% nanrow = find(all(isnan(DEM.Blank),2));
% DEM.Blank(:,nancol) = []; DEM.Blank(nanrow,:) = [];
% DEM.X(:,nancol) = [];     DEM.X(nanrow,:) = [];
% DEM.Y(:,nancol) = [];     DEM.Y(nanrow,:) = [];
% DEM.Z(:,nancol) = [];     DEM.Z(nanrow,:) = [];

%% Storglaciaren dem
clearvars -except DEM storpath outline
% generate the x,y coordinates of storglaciaren
stor = geotiffread([storpath,'stor90.tif']);
storSize = size(stor);
cx1 = min(outline(:,2));    cx2 = max(outline(:,2));
cy1 = min(outline(:,1));    cy2 = max(outline(:,1));
cx = linspace(cx1,cx2,storSize(2));
cy = linspace(cy1,cy2,storSize(1));
cy = rot90(cy,1);
[X,Y] = meshgrid(cx,cy);
mask = inpolygon(Y,X,outline(:,1), outline(:,2));
storDEM.Blank = ones(size(mask));
storDEM.Blank(~mask)=nan;
storDEM.X = X;  storDEM.Y = Y;  storDEM.Z = stor;
storDEM.Outline = outline;  
clearvars -except DEM storDEM
save('DEM.mat');

topo = DEM.Z .* DEM.Blank;
figure;
surfc(DEM.X, DEM.Y, topo);
figure
subtopo = storDEM.Z .* storDEM.Blank;
surfc(storDEM.X, storDEM.Y, subtopo);
colorbar