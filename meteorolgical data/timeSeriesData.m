function [yr,mo,dy,hr,mi,se,data,index] = timeSeriesData(timeData,timeStep,t1,t2,predata)
%% This script detects and fills gaps in time series data using autoregressive modeling 
% [timeData]: timeInput in the format of matlab datetime
% [timeStep]: time steps of desired time series e.g. hours(1)-->every 1 hr
%  help doc: https://se.mathworks.com/help/matlab/matlab_prog/generate-sequence-of-dates-and-time.html
% [t1 t2]: the start and end study time; in the format of matlab datetime
% [predata]: the original input of raw data
% the date output is in the order of year, month, day, hour, minute, second
% [data] is the output gaps filled data 
% [index]: 0 for original 1 for gaps filled data
% It will plot the original time series data and gaps filled data for visual comparison
% INTERPOLATION METHOD CAN BE CHANGED: default method is fillgaps function ,
% alternatively you can replace them in the script with fillmissing function,
% see help fillgaps/fillmissing
%
% note: if error says the size of array do not match, round the dateData
% e.g. timeData = dateshift(timeData,'start','hour');
%
% Shunan Feng: fsn.1995@gmail.com
% written for thesis work in Uppsala University, 20190220

% create a complete sequence of datetime
time = (datetime(t1):timeStep:datetime(t2))';
i = find(timeData <= t1, 1); 
if isempty(i)
    error('Start time does not exist in data')
end
i = find(timeData >= t2, 1); 
if isempty(i)
    error('End time does not exist in data')
end
fprintf('Time range of the dataset \n%s-%s\n', timeData(1),timeData(end));

% check if any repeated date
a = length(timeData) - length(unique(timeData));
if a > 0
    fprintf('%d repeated time found, taking the average value\n',a);
    G = findgroups(timeData);
    timeData = splitapply(@nanmean, timeData, G);
    predata = splitapply(@nanmean, predata, G);
end

% gap detection and filling
if length(timeData) ~= length(time)
    index = ismember(time,timeData);
    data = nan(size(time));
    dataStart = find(timeData == t1);
    dataEnd = find(timeData == t2);
    nullNum = sum(index == 0);
    fprintf('%d date gaps found \n',nullNum);
    disp(time(index == 0));
    data(index == 1) = predata(dataStart:dataEnd);
    figure;
    plot(time,data,'DisplayName','rawdata'); hold on
    nullIndex = isnan(data);
    nullNum = sum(nullIndex);
    fprintf('%d data gaps found \n',nullNum);
    disp(time(nullIndex));
    data = fillmissing(data,'linear');
%     data = fillgaps(data);
    plot(time(nullIndex),data(nullIndex),'*','DisplayName','filled');
    legend
else
    fprintf('Time seri-es is complete without date gaps\n');
    nullIndex = isnan(predata);
    nullNum = sum(nullIndex);
    fprintf('%d data gaps found \n',nullNum);
    disp(time(nullIndex));
    data = fillmissing(predata,'linear');
%     data = fillgaps(predata);
    figure;
    plot(time,predata,'DisplayName','rawdata'); hold on
    plot(time(nullIndex),data(nullIndex),'*','DisplayName','filled');
    legend
end
index = nullIndex;
[yr,mo,dy,hr,mi,se] = datevec(time);
end