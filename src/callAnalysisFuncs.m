% =========================================================================
% Master caller script for various analysis functions with the OS prefix.
% The same set of functions will be called for each column (ROI) in
% the given .xlsx spreadsheet
% 
% ------
% @param  none
% 
% @version 2023/02/26 XJ
%   changed names from Script_Run_allcodes_v2.m
%   added documentation
%   removed redundant comments
%   removed duplicated plots
% 
% @log
%   previous updated 20220506, mw;
%   20220523, SF/JK, add fft and additional numbers;
%   20220604, mw; simplify t1-t2 for add sth; correct bar edgelimit;
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================

%% Initialization
% create directory for saving figures
Folder1 = cd;
warning off MATLAB:MKDIR:DirectoryExists
mkdir([Folder1 '/0analysis']);

% import data
[duration,cellnum] = size(roi_intensity);
colors=jet(cellnum);
[i, ii]=size(firstaddsth);
peak_distance_histogram_upperlimit=200;

% output variables
p2p_hist=[];
p2p_all=[];
stat=zeros(8,cellnum);
stat_add=0;

%% make plots by iterating through all columns (ROIs)
disp(['Starting analysis of ' fname ' with '...
    num2str(cellnum) ' ROI(s)...']);
for k=1:cellnum
    disp(['    Processing ROI #' num2str(k)]);
    name = [experiment '_' num2str(k)];
    ROI_profile=roi_intensity(:,k);
    %% call analysis functions, comment out unwanted analysis plots
    OS_plot_1c(ROI_profile,name,timeinterval(k),'m')
    OS_plot_1c_3d(ROI_profile,name,timeinterval(k),'m')
    [peak_distance,p2p_stat]=OS_poincare_v4...
        (ROI_profile, name, timeinterval(k));
    OS_wavelet_v3_yPeriod(ROI_profile,name,timeinterval(k))
    stat(1:3,k)=OS_Xcorr_v3(ROI_profile, ROI_profile,...
        name,timeinterval(k));
    stat(4,k)=OS_fft(ROI_profile,name,timeinterval(k),'k');
    stat(5:10,k)=OS_alignpeaks_2c(ROI_profile,ROI_profile,...
        name,timeinterval(k),100,[0, 0.5, 0],[0, 0.5, 0]);
    
    % store outputs from OS_poincare_v4.m
    p2p_hist(:,k)=p2p_stat;
    p2p_all{k}=peak_distance;

    %% uncomment below to separate before and after adding perturbation
%     if firstaddsth(1,k)>0
%         t_add=firstaddsth(:,k);
%         t_add=t_add(~isnan(t_add));
%         ii=length(t_add);
%         
%         for j=2:ii+1
%             if j==1
%                 t1=1;
%                 t2=firstaddsth(j,k);
%             elseif j==ii+1
%                 t1=firstaddsth(j-1,k);
%                 t2=duration;
%             else
%                 t1=firstaddsth(j-1,k);
%                 t2=firstaddsth(j,k);
%             end
%             stat_add(1:3,j+(k-1)*5)=OS_Xcorr_v3...
%                   (ROI_profile(t1:t2), ROI_profile(t1:t2),...
%                       [name 't' num2str(j)],timeinterval(k));
%             stat_add(4,j+(k-1)*5)=OS_fft(ROI_profile(t1:t2),...
%                 [name 't' num2str(j)],timeinterval(k),'k');
%             stat_add(5:10,j+(k-1)*5)=OS_alignpeaks_2c...
%                 (ROI_profile(t1:t2),ROI_profile(t1:t2),...
%                 [name 't' num2str(j)],timeinterval(k),100,'b','b');
%         end
%     end
    close all
end

%% make dir for histogram and save plot and .mat file
% set up dir
warning off MATLAB:MKDIR:DirectoryExists
warning('off', 'Images:initSize:adjustingMag');
warning('off', 'MATLAB:xlswrite:AddSheet');
mkdir([Folder1 '/0histogram']);
cd([Folder1 '/0histogram']);
scrsz = get(0,'ScreenSize');
% plot
figure('Position',[scrsz(3)*0.8 scrsz(4)*0.8 scrsz(3)*0.2 scrsz(4)*0.2],...
    'PaperPosition',[0.25 2.5 3 2]);
edges = [10:10: peak_distance_histogram_upperlimit];
center=edges+5;
bar(center(1:length(center)-1),sum(p2p_hist(:,:)'))
xlabel('|P| (sec)');
% print('-depsc','-r300', [experiment '_p2p_Histo.eps']);
saveas(gca, [experiment '_p2p_Histo.png']);
save([experiment '_peaks.mat'],'p2p_hist','p2p_all');
cd('..');

%% make dir for stat and save .xlsx and .mat file
mkdir([Folder1 '/0stat']);
cd([Folder1 '/0stat']);
save([experiment '_stat.mat'],'stat','stat_add');
C={'Xcorr:drop_half-peak'; 'Xcorr:valley-peak'; 'Xcorr: 2nd peak';...
    'FFT';'AP:peak-rise'; 'AP: drop-peak'; 'AP: peak-rise_half';...
    'AP: drop_half-peak';'AP: peak-v2'; 'AP: valley-peak'};
writecell(C,[experiment '_stat.xlsx'],'Sheet',1,'Range','A2:A11');
T = table(stat);
writetable(T,[experiment '_stat.xlsx'],'Sheet',1,'Range','B1');
T = table(stat_add);
writetable(T,[experiment '_stat.xlsx'],'Sheet',2,'Range','B1');
writecell(C,[experiment '_stat.xlsx'],'Sheet',2,'Range','A2:A11');
C={'One cell every 5 columns'};
writecell(C,[experiment '_stat.xlsx'],'Sheet',2,'Range','A1');
cd('..');

disp('...Completed!')

