%% metwrite.m
%  making a check of meteorological data from Tarfala weather station
%   peter.jansson@2000-05-07 -> 2002-04-21

%% Define year and read data
Year  = 2008;
indata = dlmread('TRSmet2008.csv',',');

%% search and find data of different types
dind = indata(:,1) == 124;
hind = find(indata(:,1) == 101);
tind = find(indata(:,1) == 103);

%% Split data of different kinds
daily  = indata(dind,:);
hourly = indata(hind,1:26);
synop  = indata(tind,1:5);
clear indata 

% Define columns of data to convert to a date string.
%  Note dummy seconds variable
Hyr = hourly(:,2);
Hjd = hourly(:,3);
Hhhmm = hourly(:,4);
Hs = zeros(length(hourly(:,1)),1);
Dyr = daily(:,2);
Djd = daily(:,3);
Dhhmm = daily(:,4);
Ds = zeros(length(daily(:,1)),1);
Syr = synop(:,2);
Sjd = synop(:,3);
Shhmm = synop(:,4);
Ss = zeros(length(synop(:,1)),1);
% Call the string funmction.
[HourlyString] = jday2date(Hyr,Hjd,Hhhmm,Hs);
[DailyString] = jday2date(Dyr,Djd,Dhhmm,Ds);
[SynopString] = jday2date(Syr,Sjd,Shhmm,Ss);

[nrows, ncols] = size(hourly);
%Rhcutoffdate = '2003-07-22 19:00:00';
%Rhind = find(datenum(HourlyString)>datenum(Rhcutoffdate));
%hourly(Rhind,15) = NaN;

fidT=fopen(['TRS_met_',num2str(Year),'_Temperature.csv'],'w');
fidRh=fopen(['TRS_met_',num2str(Year),'_Relative_humidity.csv'],'w');
fidW=fopen(['TRS_met_',num2str(Year),'_Wind.csv'],'w');
fidB=fopen(['TRS_met_',num2str(Year),'_Barometric_pressure.csv'],'w');
fidP=fopen(['TRS_met_',num2str(Year),'_Precipitation.csv'],'w');
fidR=fopen(['TRS_met_',num2str(Year),'_Radiation.csv'],'w');
%fidSR=fopen(['TRS_met_',num2str(Year),'_Snow_depth.csv'],'w');
% print the different files
for row=1:nrows
    fprintf(fidT,'%19s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.0f,%.2f,%.0f\n',HourlyString(row,:),hourly(row,[5:7 18:20 22:25])); 
    fprintf(fidRh,'%19s,%.1f,%.1f\n',HourlyString(row,:),hourly(row,[8 21])); 
    fprintf(fidW,'%19s,%.1f,%.1f,%.4f,%.2f,%.0f\n',HourlyString(row,:),hourly(row,[9:11 16:17])); 
    fprintf(fidB,'%19s,%.1f\n',HourlyString(row,:),hourly(row,26)); 
    fprintf(fidP,'%19s,%.2f\n',HourlyString(row,:),hourly(row,13)); 
    fprintf(fidR,'%19s,%.2f\n',HourlyString(row,:),hourly(row,12)); 
%    fprintf(fidSR,'%19s,%.3f\n',HourlyString(row,:),hourly(row,15:16)); 
end

[mrows, mcols] = size(daily);
% open file for daily output an dprint
fidD=fopen(['TRS_met_',num2str(Year),'_Daily_data.csv'],'w');
for row=1:mrows
    fprintf(fidD,'%19s,%.2f,%.2f,%.2f,%.1f,%.2f,%.0f,%.2f,%.0f,%.1f,%.0f,%.1f,%.1f,%.1f,%.1f,%.2f\n',DailyString(row,:),daily(row,5:19)); 
end

[krows, kcols] = size(synop);
% open file for daily output an dprint
fidD=fopen(['TRS_met_',num2str(Year),'_Synop_data.csv'],'w');
for row=1:krows
    fprintf(fidD,'%19s,%.2f\n',SynopString(row,:),synop(row,5)); 
end

fclose('all');

b=[[num2str(Year),'-01-01'];
   [num2str(Year),'-02-01'];
   [num2str(Year),'-03-01'];
   [num2str(Year),'-04-01'];
   [num2str(Year),'-05-01'];
   [num2str(Year),'-06-01'];
   [num2str(Year),'-07-01'];
   [num2str(Year),'-08-01'];
   [num2str(Year),'-09-01'];
   [num2str(Year),'-10-01'];
   [num2str(Year),'-11-01'];
   [num2str(Year),'-12-01']];

format short g
H = [datenum(HourlyString) hourly(:,5:26)];
bind = find(H(:,23)<500);
h(bind,23) = NaN; % replace all null values with NaN for barometric pressure
D = [datenum(DailyString) daily(:,5:21)];
TickNum = datenum(b);
TickDate = '1 Jan.|1 Feb.|1 Mar.|1 Apr.|1 May|1 Jun.|1 Jul.|1 Aug.|1 Sep.|1 Oct.|1 Nov.|1 Dec.'; 
%return

StartDate = datenum([num2str(Year),'-01-01']);
axismin = StartDate;
axismax = datenum([num2str(Year+1),'-01-01']);
textmin = axismin + 5;

%% Figures
% setting up constants for plotting
screenrect = get(0,'screensize'); screenwidth = screenrect(3);
screenheight = screenrect(4); figwidth = floor(0.9*screenwidth);
figheight = floor(0.9*screenheight);

figure1=figure('position', [(screenwidth/2-figwidth/2) (screenheight/2-figheight/2) figwidth figheight],...
        'units','pixels','NumberTitle','off','Name',['Meteorological data from Tarfala ',num2str(Year)]);
orient landscape
set(gcf, 'PaperType', 'A4');

n=1; % for plotting selected points, n=4 is pseudo hourly data
rows=6;
subplot(rows,1,1)
plot(H(1:n:end,1),H(1:n:end,2),'g',H(1:n:end,1),H(1:n:end,3),'b',...
     H(1:n:end,1),H(1:n:end,4),'r',[axismin axismax],[0 0],'k')
  axis([axismin axismax -20 20]); 
   text(textmin,15,'Air temperature');
   legend('Stevenson (Pt100)','Young (Pt100)','Vented T','Location','northwest')
    ylabel('(^\circ C)');
    title(['Tarfala Research Station meteorological data for ',num2str(Year)])
     set(gca,'XTick',[]); %hold off
subplot(rows,1,2)
plot(H(1:n:end,1),H(1:n:end,5),'b')
  axis([axismin axismax 0 100]); 
   text(textmin,70,'Relative humidity');
   legend('Vented Rh','Location','southwest')
    ylabel('(%)');
     set(gca,'XTick',[]); %hold off
subplot(rows,1,3)
[AX,H1,H2] = plotyy(H(1:n:end,1),H(1:n:end,9),H(1:n:end,1),H(1:n:end,23));
 hold on
  text(textmin,800,'Incoming global radiation/barometric pressure');
   set(get(AX(1),'Ylabel'),'String','(W/m^2)');
    set(get(AX(2),'Ylabel'),'String','(hPa)');
     set(AX(1),'xlim',[axismin axismax],'ylim',[0 1000],'XTick',[],'YColor','k')
      set(AX(2),'xlim',[axismin axismax],'ylim',[830 920],'XTick',[],'YColor','k')
subplot(rows,1,4)
plot(D(1:n:end,1),D(1:n:end,10),'r.','MarkerSize',10)
 hold on;
  plot(H(1:n:end,1),H(1:n:end,6),'b')
   axis([axismin axismax 0 40]); 
    text(textmin,15,'Wind Speed');
     ylabel('(m/s)');
      set(gca,'XTick',[]); hold off
subplot(rows,1,5)
plot(H(1:n:end,1),H(1:n:end,7),'b.')
  axis([axismin axismax 0 360]); 
  set(gca,'YTick',[0 90 180 270 360],'YTickLabel','N|E|S|W|N')
   text(textmin,300,'Wind direction');
    ylabel('(^\circ)');
     set(gca,'XTick',[]); %hold off
subplot(rows,1,6)
bar(H(1:n:end,1),H(1:n:end,10),'b')
hold on; 
%plot(H(1:n:end,1),H(1:n:end,11),'r')
legend('Precipitation', 'Location','northeast')
% legend('Snow depth (SR50)','Location','northeast')
   axis([axismin axismax 0 5]); 
   text(textmin,3,'Precipitation');
    ylabel('(mm/hr)');
    xlabel (['Date (in ',num2str(Year),')'])
      set(gca,'XTick',TickNum,'XTickLabel',TickDate); %hold off

%% Calculate monthly values of data including number of data
%Find leap year
if mod(Year, 400) == 0
   LastFeb = [num2str(Year),'-02-29']; % leap year
elseif mod(Year, 4) == 0 && mod(Year, 100) ~= 0
   LastFeb = [num2str(Year),'-02-29']; % leap year
else
   LastFeb = [num2str(Year),'-02-28']; % ordinary year
end

%Initialize summary
Sum = zeros(12,20); 

for k=1:12 
  switch k % select mont and criteria for extracting data from that month
      case 1
          avgind = find(H(:,1) < datenum([num2str(Year),'-02-01']));
      case 2
          avgind = find(H(:,1) > datenum([num2str(Year),'-01-31']) & H(:,1) < datenum(LastFeb));
      case 3
          avgind = H(:,1) > datenum(LastFeb) & H(:,1) < datenum([num2str(Year),'-04-01']);
      case 4
          avgind = H(:,1) > datenum([num2str(Year),'-03-31']) & H(:,1) < datenum([num2str(Year),'-05-01']);
      case 5
          avgind = H(:,1) > datenum([num2str(Year),'-04-31']) & H(:,1) < datenum([num2str(Year),'-06-01']);
      case 6
          avgind = H(:,1) > datenum([num2str(Year),'-05-31']) & H(:,1) < datenum([num2str(Year),'-07-01']);
      case 7
          avgind = H(:,1) > datenum([num2str(Year),'-06-31']) & H(:,1) < datenum([num2str(Year),'-08-01']);
      case 8
          avgind = H(:,1) > datenum([num2str(Year),'-07-31']) & H(:,1) < datenum([num2str(Year),'-09-01']);
      case 9
          avgind = H(:,1) > datenum([num2str(Year),'-08-31']) & H(:,1) < datenum([num2str(Year),'-10-01']);
      case 10
          avgind = H(:,1) > datenum([num2str(Year),'-09-30']) & H(:,1) < datenum([num2str(Year),'-11-01']);
      case 11
          avgind = H(:,1) > datenum([num2str(Year),'-10-31']) & H(:,1) < datenum([num2str(Year),'-12-01']);
      case 12
          avgind = H(:,1) > datenum([num2str(Year),'-11-30']) & H(:,1) < datenum([num2str(Year+1),'-01-01']);
  end
  temp       = H(avgind,2); % monthly average temperature 1
   Sum(k,1)  = mean(temp(~isnan(temp)));     
    Sum(k,2) = length(temp(~isnan(temp)));
     clear temp
  temp       = H(avgind,3);% monthly average temperature 2
   Sum(k,3)  = mean(temp(~isnan(temp)));        
    Sum(k,4) = length(temp(~isnan(temp)));
     clear temp
  temp       = H(avgind,4); % monthly average temperature 3
   Sum(k,5)  = mean(temp(~isnan(temp)));        
    Sum(k,6) = length(temp(~isnan(temp)));
     clear temp
  temp       = H(avgind,4); % monthly totalized positive temperature 3
   Sum(k,7)  = sum(temp(temp(~isnan(temp))>0)); 
    Sum(k,8) = length(temp(~isnan(temp(temp>0))));
     clear temp
  temp       = H(avgind,5); % monthly average humidity
   Sum(k,9)  = mean(temp(~isnan(temp)));        
    Sum(k,10) = length(temp(~isnan(temp)));
     clear temp
  temp        = H(avgind,9); % monthly average radiation
   Sum(k,11)   = mean(temp(~isnan(temp)));        
    Sum(k,12) = length(temp(~isnan(temp)));
     clear temp
  temp        = H(avgind,9); % monthly sum of radiation
   Sum(k,13)  = sum(temp(temp(~isnan(temp))>0));  
    Sum(k,14) = length(temp(~isnan(temp(temp>0))));
     clear temp
  temp        = H(avgind,10); % monthly totalized precipitation
   Sum(k,15)  = sum(temp(~isnan(temp)));  
    Sum(k,16) = length(temp(~isnan(temp)));
     clear temp
  temp        = H(avgind,6); % monthly average wind speed
   Sum(k,17)  = mean(temp(~isnan(temp)));        
    Sum(k,18) = length(temp(~isnan(temp)));
     clear temp
  temp        = H(avgind,23); % monthly average barometric pressure
   Sum(k,19)  = mean(temp(~isnan(temp)));        
    Sum(k,20) = length(temp(~isnan(temp)));
     clear temp
  clear avgind
end

try
    fidSum = fopen(['TRS_met_summary_',num2str(Year),'.tex'], 'w');
catch ME
    fclose(fidSum);
    error('Error writing to output file');
end

Units = ...
['(\si{\degreeCelsius})                 ';
 '$n$                                   ';
 '(\si{\degreeCelsius})                 ';
 '$n$                                   ';
 '(\si{\degreeCelsius})                 ';
 '$n$                                   ';
 '(\si{\degreeCelsius})                 ';
 '$n$                                   ';
 '(\si{\percent})                       ';
 '$n$                                   ';
 '(\si{\watt\per\meter\squared})        ';
 '$n$                                   ';
 '(\si{\watt\per\meter\squared})        ';
 '$n$                                   ';
 '(\si{\milli\meter})                   ';
 '$n$                                   ';
 '(\si{\meter\per\second})              '; 
 '$n$                                   '; 
 '(\si{\hecto\pascal})                  '; 
 '$n$                                   ' ];

fprintf(fidSum,'\\begin{table}[ht]\n'); 
fprintf(fidSum,'\\caption{Monthly averages of meteorological parameters from the Tarfala Research Station automatic weather station \\Year.}\n'); 
fprintf(fidSum,'\\begin{center}{\\scriptsize\n'); 
fprintf(fidSum,'\\begin{tabular}{l d{0} d{0} d{0} d{0} d{0} d{0} d{0} d{0} d{0} d{0} d{0} d{0}}\n'); 
fprintf(fidSum,'\\toprule\n'); 
fprintf(fidSum,' &\\multicolumn{1}{c}{Jan.} &\\multicolumn{1}{c}{Feb.}&\\multicolumn{1}{c}{Mar.}&\\multicolumn{1}{c}{Apr.}&\\multicolumn{1}{c}{May }&\\multicolumn{1}{c}{Jun.}&\\multicolumn{1}{c}{Jul.}&\\multicolumn{1}{c}{Aug.}&\\multicolumn{1}{c}{Sep.}&\\multicolumn{1}{c}{Oct.}&\\multicolumn{1}{c}{Nov.}&\\multicolumn{1}{c}{Dec.}\\\\ \n'); 
l = 1;k = 1;
%1 avg T (Stevenson)
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Average air temperature (Stevenson)} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%2 avg T
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Average air temperature (Young)} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%3 avg T
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Average air temperature} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%4 sum pos T
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Positive degree sum} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%5 avg Rh
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Average relative humidity} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%6 avg Ir
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Average incoming global radiation} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%7 Sum Ir
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Global incoming energy sum} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%10 sum P
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Totalized precipitation} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.2f &%.2f &%.2f &%.2f &%.2f &%.2f &%.2f &%.2f &%.2f &%.2f &%.2f &%.2f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%11 avg wsp
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Average wind speed} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
l = l + 1; k = k + 2;
%12 avg barP
fprintf(fidSum,'\\midrule\n \\multicolumn{13}{l}{Average barometric pressure} \\\\ \\\\ \n  \\multicolumn{1}{r}{%s} &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f &%.1f \\\\ \n \\multicolumn{1}{r}{%s} &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f &%.0f  \\\\', ...
         Units(k,1:37),   Sum(1,k),    Sum(2,k),   Sum(3,k),   Sum(4,k),   Sum(5,k),...
                          Sum(6,k),    Sum(7,k),   Sum(8,k),   Sum(9,k),   Sum(10,k),...
                          Sum(11,k),   Sum(12,k),...
         Units(k+1,1:37), Sum(1,k+1),  Sum(2,k+1), Sum(3,k+1), Sum(4,k+1), Sum(5,k+1),...
                          Sum(6,k+1),  Sum(7,k+1), Sum(8,k+1), Sum(9,k+1), Sum(10,k+1),...
                          Sum(11,k+1), Sum(12,k+1) );
fprintf(fidSum,'\\bottomrule\n'); 
fprintf(fidSum,'\\end{tabular}}\n'); 
fprintf(fidSum,'\\end{center}\n'); 
fprintf(fidSum,'\\label{tab:Summary}\n'); 
fprintf(fidSum,'\\end{table}\n'); 

 fclose(fidSum);
