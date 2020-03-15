function [climateData,date] = timeSelection(dataInput,timeInput,t1,t2)
r1 = find(timeInput == t1);
r2 = find(timeInput == t2);
climateData = dataInput(r1:r2);
date = timeInput(r1:r2);
fprintf('Selected data from %s to %s\n', t1, t2);
end
