function [peak_distance,p2p_stat] = OS_poincare_v4...
    (ROI_profile, name, timeinterval)
% =========================================================================
% For analyzing traces with irregular periodicity.
% Finds peaks of oscillations and plots:
%   histogram of peak to peak distances
%   trace of oscillation with peaks highlighted
%   period (n) vs. period (n+1)
% 
% ------
% @param  ROI_profile: time series array of ROI intensities
% @param name: name of experiment and ROI number
% @param timeinterval: image stack acquisition time interval (in seconds)
% 
% @return peak_distance: distance between peaks
% @return p2p_stat: info from histogram
% 
% @syntax OS_plot_1c_3d(intensity(1:400,3),'name',3,'r');
% 
% @version 2023/02/26 XJ
%   changed name to OS_poincare_v4.m for pushing to github
%   added documentation and comments; improved style and readability;
%   removed redundancies
%   removed unused plots: next amplitude, next period linear piecewise
%   removed unused input param peak_distance_histogram_upperlimit
%   combined 30/60 min plots into a plot with xlim [0 timeaxis(end)]
%   commented out separate plots and modified combined p2p plot
%   removed second copy of figures saved in Folder2
%   removed unused smooth_parameter and 
% 
% @log
%   22/6/4, Min, minor cosmetics udpate, consistent font size for figure
%   22/5/7 Min, change names of variable, figure label, folder name, etc.
%               to be more consistent. add two output figures
%               (standalone IPI vs. time, Next period plot)
%   22/4/18 Min updated to be: OS_poincare_v3.m;
%           1. update radius = 20/timeinterval;
%           2. add 3d plot of peak n vs. n+1 vs. n+2, but this poincare 
%               3d plot and poincare plot is not super-informative yet. 
%               The 3d plot of whole trace OS_plot_1c_3d.m might be more 
%               useful to show limit cycle/attractor
%           3. add next peak piecewise linear map
%   22/4/9 Min updated to be a function: OS_poincare_v2.m;
%           1. change input methods
%           2. add histogram on peak to peak distance
%           3. add next-period map
%           4. add period vs. time in order to see period doubling events
%   21/8/2 Min updated to do next-peak map;
%   19/8/16 Min wrote OSpoincare.m to do poincare (next amplitude) map;
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================

    %% Initialization
    % load the traces
    ROI_profile=ROI_profile(~isnan(ROI_profile));
    ROI_profile=double(ROI_profile);
    ll=length(ROI_profile);
    timeaxis=(0:timeinterval:(ll-1)*timeinterval)/60;
    % parameters for defining and finding peaks
    radius = round(20/timeinterval);
    cutoff = 0.2;
    % parameters for plotting
    LineW=0.4;
    colorofcurve='k';
    colorofcurve2='m';
    scrsz = get(0,'ScreenSize');
    peak_distance_histogram_upperlimit = 200;
    % directory for saving plots
    savedir = [cd '/0analysis'];
    warning off MATLAB:MKDIR:DirectoryExists
    warning('off', 'Images:initSize:adjustingMag');
    mkdir(savedir);

    %% Find peaks
    % Peaks are defined to be greater than the local neighborhood 
    % with a specified radius.
    allpeaks = zeros(ll-radius);
    for iii = 1:ll - radius
        product = 1;
        for jjj = 1:radius*2+1
            product = product*(ROI_profile(iii) >= ...
                ROI_profile(max(1, (iii-radius-1+jjj))));
        end
        allpeaks(iii)=product;
    end
    allpeaksindex = find(allpeaks==1);

    %% if an threshold of intensity is needed to define peaks
    % define baseline as the average of lowest 50 points
    new = sort(ROI_profile);
    baseline = mean(new(1:50));
    hh = (ROI_profile(allpeaksindex)-baseline) > ...
        cutoff*(max(ROI_profile)-baseline);
    allpeaksindex = allpeaksindex(hh);
    OS_peak=ROI_profile(allpeaksindex);
    lll=length(OS_peak);

% uncomment below to obtain individul plot of the trace
%     %% plot curve with + sign and all peak/valley highlighted
%     figure('Position',[scrsz(3)*0.3 scrsz(4)*0.8 scrsz(3)*0.6...
%         scrsz(4)*0.2],'PaperPosition',[1 12 12 1]);
%     plot(timeaxis,ROI_profile,'+-','Color',colorofcurve,...
%         'MarkerSize',4,'LineWidth',LineW/2);
%     hold on;
%     ax1 = gca;
%     % highlight all the peaks w filled dot
%     plot(timeaxis(allpeaksindex),ROI_profile(allpeaksindex),...
%         'm', 'MarkerSize',10,'Parent',ax1);
%     set(gca,'XLim',[0 timeaxis(end)]);
%     hold on;
%     cd(savedir);
%     saveas(gca, [name '_peak_cutoff' num2str(cutoff) '.png']);
%     print('-depsc','-r300', [name '_peak__cutoff'...
%         num2str(cutoff) '_.eps']);
%     cd('..');

    %% plot a histogram for the peak-to-peak distances   
    peak_distance = diff(allpeaksindex)*timeinterval;
    figure('Position',[scrsz(3)*0.8 scrsz(4)*0.8 scrsz(3)*...
        0.2 scrsz(4)*0.2], 'PaperPosition',[0.25 2.5 3 2]);
    edges = [10:10: peak_distance_histogram_upperlimit];
    h=histogram(peak_distance,edges);
    xlabel('|P| (sec)');
    p2p_stat=h.Values;
    cd(savedir);
    saveas(gca, [name '_p2pHisto.png']);
    % print('-depsc','-r300', [name '_p2pHisto.eps']);
    cd('..');

    %% plot peak to peak distance vs. time; period n vs. period (n+1);
    % alongside the main trace with peak/valley highlighted
    peak_time=timeaxis(allpeaksindex(1:lll-1));
    peak_distance(peak_distance>400)=nan;
    llll=length(peak_distance);
    figure('Position',[1 scrsz(4)*0.1 scrsz(3)*0.9 scrsz(4)*0.2],...
        'PaperPosition',[0.25 2.5 12 2]);
    subplot (1, 8, [1:6])
    % ensure that x label is inside of the figure area
    v = get(gca,'Position');
    set(gca,'Position',[v(1) v(2)*2.5 v(3) v(4)*0.6])
    % plot trace
    plot(timeaxis,ROI_profile,'+-','Color',colorofcurve,...
        'MarkerSize',4,'LineWidth',LineW/2);
    set(gca,'XLim',[0 timeaxis(end)]);
    hold on;
    % highlight all the peaks w filled dot
    plot(timeaxis(allpeaksindex),ROI_profile(allpeaksindex),...
        'm.', 'MarkerSize',10);
    xlabel('Time (mins)')
    % period vs. time
    subplot (1, 8,7)
    plot(peak_time,peak_distance,'.','Color',...
        colorofcurve2,'MarkerSize',12);
    set(gca,'YLim',[0 200]);
    xlabel('Time (mins)')
    ylabel('|P|')
    axis square
    % period (n) vs. period (n+1)
    subplot (1, 8,8)
    plot(peak_distance(1:llll-1),peak_distance(2:llll),'.',...
        'Color',colorofcurve2,'MarkerSize',12);
    axis equal
    axis square
    set(gca,'XLim',[0 200]);
    set(gca,'YLim',[0 200]);
    xlabel('P')
    ylabel('P+1')
    % save figure
    cd(savedir);
    saveas(gca, [name '_p2p.png']);
    % print('-depsc','-r300', [name '_p2p__.eps']);
    cd('..');

% uncomment below to obtain separate file of the time vs |P| plot
%     figure('Position',[scrsz(3)*0.4 scrsz(4)*0.3 ...
%       scrsz(3)*0.2 scrsz(4)*0.2],'PaperPosition',[0.6 6 2 2]);
%     plot(peak_time,peak_distance,'.','Color',...
%       colorofcurve2,'MarkerSize',12)
%     set(gca,'YLim',[0 200]);
%     xlabel('T (min)','FontSize', 10)
%     ylabel('IPI (s)','FontSize', 10)
%     axis square
%     cd(savedir);
%     saveas(gca, [name '_p2p_.png']);
%     % print('-depsc','-r300', [name '_p2p_.eps']);
%     cd('..');

% uncomment below to obtain separate file of the P(n) vs.P(n+1) plot
%     X0=peak_distance(1:llll-1);
%     X1=peak_distance(2:llll);
%     figure('Position',[scrsz(3)*0.6 scrsz(4)*0.3 scrsz(3)* ...
%         0.2 scrsz(4)*0.2],'PaperPosition',[0.6 6 2 2]);
%     plot(X0,X1,'.','Color',colorofcurve2,'MarkerSize',12)
%     axis equal
%     axis square
%     set(gca,'XLim',[0 200]);
%     set(gca,'YLim',[0 200]);
%     xlabel('P (s)','FontSize', 10);
%     ylabel('P+1 (s)','FontSize', 10)
%     cd(savedir);
%     saveas(gca, [name '_p2p_nextPeriod_.png']);
%     % print('-depsc','-r300', [name '_p2p_nextPeriod_.eps']);
%     cd('..');

close all
