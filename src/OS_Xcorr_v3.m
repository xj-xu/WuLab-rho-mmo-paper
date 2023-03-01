function stat=OS_Xcorr_v3(ROI_profile1, ROI_profile2,name,timeinterval)
% =========================================================================
% Computes cross-correlation of two input signals and plots the lag.
% The autocorrelation is effectively computed if ROI_profile1 is 
% the same as ROI_profile2. 
%
% ------
% @param  ROI_profile1: time series array of first ROI intensities
% @param  ROI_profile2: time series array of second ROI intensities
% @param name: name of experiment and ROI number
% @param timeinterval: image stack acquisition time interval (in seconds)
% 
% @return stat: arrray with 3 numbers characterizing the peaks
% 
% @version 2023/02/28 XJ
%   added documentation and comments; improved style and readability;
%   removed redundancies
%   made optional: plot with dots; display table of stats
% 
% @log
%   22/6/4, Min, minor udpate, deleted 2-color related codes
%   22/6/4, Min, minor cosmetics udpate, consistent font size for figure
%   2022/5/10 JK added code to calculate the second peak
%   2022/5/6 mw change to OS_Xcorr_v3.m add code to add 
%               resampling /calculation of half-maximal time point
%   2022/4/9 mw change cross_corr.m to OS_Xcorr_v2.m to be included 
%               in Script to run all codes. Code works for 1-color;
%               but some lines to be used for 2-color not deleted.
%   2019/8/14 mw adapted based on corr_phaselag.m to be used 
%               for draw2colorwavelet.m
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================

    %% Initialization
    % input
    X=ROI_profile1(~isnan(ROI_profile1));
    Y=ROI_profile2(~isnan(ROI_profile2));
    ll=length(X);
    timeaxis=0:timeinterval:(ll-1)*timeinterval;
    % parameter used
    maxlags=200;  % determines the width of Xcorr plot
    scrsz = get(0,'ScreenSize');
    % directory for saving plots
    savedir = [cd '/0analysis'];
    warning off MATLAB:MKDIR:DirectoryExists
    warning('off', 'Images:initSize:adjustingMag');
    mkdir(savedir);
    % resample data to every 1 sec
    x1 = spline(timeaxis,X,[1:1:ll*timeinterval]);
    y1 = spline(timeaxis,Y,[1:1:ll*timeinterval]);
    [covariance,lags] = xcov(x1,y1,maxlags,'coeff');
    
    %% plot and save cross correlation
    figure('Position',[scrsz(3)*0.8 scrsz(4)*0.8 scrsz(3)*0.3...
        scrsz(4)*0.3],'PaperPosition',[0.25 2.5 2.0 2.0]);
    plot(lags,covariance,'.-','Color',[0.5 0.5 0.5],'LineWidth',1);
    xlabel('Lag (s)','FontSize', 10);
    set(gca,'YLim',[-0.5 1]);
    % save plot
    cd(savedir);
    saveas(gca, [name '_Xcorr.png']);
    %     print('-depsc','-r150', [name '_Xcorr_.eps']);
    cd('..');
    
    %% calculate Xcorr attributes for returning stats
    % find half-maximal point (covariance=0.5)
    xlimit=maxlags;
    trace1_d1 = gradient(covariance);
    ll=length(trace1_d1);
    peak=find(covariance==max(covariance));
    idx=find(covariance(1:ll-1)>0.5 & covariance(2:ll)<0.5);
    idx2=find(idx>xlimit & idx<xlimit*2);
    if length(idx2)>0
        drop_half=idx(idx2(1));
    else
        drop_half=peak;
    end
    % find the second peak (JK updated)
    peak2Index = find(trace1_d1(1:ll-1)>0 & trace1_d1(2:ll)<0);
    idx2_peak2=find(peak2Index>(xlimit+40) & peak2Index<xlimit*2);
    if length(idx2_peak2)<1
        peak2=ll;
    else
        peak2=peak2Index(idx2_peak2(1));
    end
    % find valley
    valleyIndex = find(trace1_d1(1:ll-1)<0 & trace1_d1(2:ll)>0);
    idx2_valley=find(valleyIndex>(xlimit+2) & valleyIndex<xlimit*2); % find index after peak ,
    if length(idx2_valley)<1
        valley=ll;
    else
        valley=valleyIndex(idx2_valley(1));
    end
    
    %% uncomment below to overplot stats with dots
%     ty=[-xlimit:1:xlimit];
%     hold on
%     plot(ty(drop_half),covariance(drop_half),'g.', 'MarkerSize',5); % plot the dot
%     text(ty(drop_half)+3,covariance(drop_half),num2str(drop_half-peak),'FontSize', 6); % use rise y position so it is more aligned
%     hold on
%     plot(ty(valley),covariance(valley),'.','Color',[0.7 0.7 0.7], 'MarkerSize',5); % plot the dot
%     if valley<ll
%         text(ty(valley)+3,covariance(valley),num2str(valley-peak),'FontSize', 6);
%     end
%     hold on 
%     plot(ty(peak2),covariance(peak2),'m.','MarkerSize',5);
%     text(ty(peak2)+3,covariance(peak2),num2str(peak2-peak),'FontSize',6);
%     % save plot
%     cd(savedir);
%     saveas(gca, [name '_Xcorr_dots.png']);
%     % print('-depsc','-r150', [name '_Xcorr_d.eps']);
%     cd('..');
        
    %% return stat values
    stat(1)=drop_half-peak;
    stat(2)=valley-peak;
    stat(3)=peak2-peak;
    % uncomment below to display table of stat values returned
%     T = array2table([drop_half-peak,valley-peak,peak2-peak], ...
%         'VariableNames', {'Half-max','Valley','Second peak'},...
%         'RowName',{'X-corr'}); 
%     disp(T) 

    close all
