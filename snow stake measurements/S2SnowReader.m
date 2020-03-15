%% snow mapping for winter precipitation estimation
%% Snow
% snow 2010-2011 is using rt90_0.0_gon_v
% 
% 2012-                   sweref_99_tm

clearvars
% load('DEM.mat');
filepath = 'sg_mb_input\snow\';
subdir = dir(filepath);
for i = 3:length(subdir)
    yearNum = regexp(subdir(i).name,'[0-9]','match');
    yearNum = str2double(cell2mat(yearNum));
    if yearNum < 2012
        proj = 'rt90_2.5_gon_v';
    else
        proj = 'sweref_99_tm';
    end
    rawdata = dlmread([filepath,subdir(i).name]);
    gaps = find(isnan(rawdata(:,3)));
    rawdata(gaps,:) = [];
    [snow.Y, snow.X] = SWEREF2WGS84(proj,rawdata(:,2),rawdata(:,1));
    snow.snow = rawdata(:,3);
    snow.year = yearNum;    snow.unit = 'cm';
%     snowGrid = griddata(snow.X,snow.Y,snow.snow,storDEM.X,storDEM.Y,'v4');
    save(['sg_mb_output\snow\',subdir(i).name(1:end-4),'.mat'],'snow');
end
%% density
clearvars
load('densPosition.mat');
[position(:,2),position(:,1)] = SWEREF2WGS84('sweref_99_tm',position(:,2),position(:,1));
filepath = 'sg_mb_input\dens\';
subdir = dir(filepath);
%     figure;
%     hold on
for i = 3:length(subdir)
    yearNum = regexp(subdir(i).name,'[0-9]','match');
    yearNum = str2double(cell2mat(yearNum));
    rawdata = dlmread([filepath,subdir(i).name]);
    if yearNum > 2016
        [density.Y, density.X] = SWEREF2WGS84('sweref_99_tm',rawdata(:,2),...
            rawdata(:,1));
%         density.X = rawdata(:,1);   density.Y = rawdata(:,2) ;
        density.Z = rawdata(:,3);   density.depth = rawdata(:,4)*100;
        density.density = rawdata(:,5);
        density.densityBulk = rawdata(:,6);
    elseif yearNum < 2015
        density.ID = rawdata(:,11); density.density = rawdata(:,6);
%         density.ID = rawdata(:,11); density.density = rawdata(:,9);
        density.depth = rawdata(:,7);   
        density.X = ones(size(density.ID));
        density.Y = ones(size(density.ID));
        density.Z = ones(size(density.ID));
        for m = 1:max(density.ID)
            G = find(density.ID == position(m,4));
            density.X(G) = position(m,1);
            density.Y(G) = position(m,2);
            density.Z(G) = position(m,3);
        end
    else
        density.ID = rawdata(:,13); density.density = rawdata(:,8);
%         density.ID = rawdata(:,13); density.density = rawdata(:,11);
        density.depth = rawdata(:,9);
        density.X = ones(size(density.ID));
        density.Y = ones(size(density.ID));
        density.Z = ones(size(density.ID));
        for m = 1:max(density.ID)
            G = find(density.ID == position(m,4));
            density.X(G) = position(m,1);
            density.Y(G) = position(m,2);
            density.Z(G) = position(m,3);
        end
    end
    density.mdl = fitlm(density.depth, density.density.*density.depth);
    figure;
    plot(density.mdl);
    ylabel('snow cm w.e.'); xlabel('depth cm');
%     figure; scatter(density.depth, density.density.*density.depth);
    title(num2str(yearNum));
    disp(yearNum);
    disp(density.mdl);
%     G = findgroups(density.Z);
%     density.Xa = splitapply(@nanmean,density.X,G);
%     density.Ya = splitapply(@nanmean,density.Y,G);
%     density.Za = splitapply(@nanmean,density.Z,G);
%     density.densityAve = splitapply(@nanmean,density.density,G);
    
    density.year = yearNum; density.densunit = 'g/cm3'; density.deptunit = 'cm';
    save(['sg_mb_output\density\',subdir(i).name(1:end-4),'.mat'],'density');
%     plot(density.depth, density.density);
end

%% melt
clearvars
% load('DEM.mat');
filepath = 'sg_mb_input\melt\';
subdir = dir(filepath);
for i = 3:length(subdir)
    yearNum = regexp(subdir(i).name,'[0-9]','match');
    yearNum = str2double(cell2mat(yearNum));
    if yearNum < 2012
        proj = 'rt90_2.5_gon_v';
    else
        proj = 'sweref_99_tm';
    end
    rawdata = dlmread([filepath,subdir(i).name]);
    gaps = find(isnan(rawdata(:,4)));
    rawdata(gaps,:) = [];
    [melt.Y, melt.X] = SWEREF2WGS84(proj,rawdata(:,2),rawdata(:,1));
    melt.melt = rawdata(:,4);
    melt.year = yearNum;    melt.unit = 'm';
%     snowGrid = griddata(snow.X,snow.Y,snow.snow,storDEM.X,storDEM.Y,'v4');
    save(['sg_mb_output\melt\',subdir(i).name(1:end-4),'.mat'],'melt');
end
