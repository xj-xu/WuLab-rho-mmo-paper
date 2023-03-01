function OS_plot_1c_3d(ROI_profile,name,timeinterval,colorofcurve)
% =========================================================================
% Plots 3d figures showing time evolution of T+n vs T+2n
% 
% ------
% @param  ROI_profile: time series array of ROI intensities
% @param name: name of experiment and ROI number
% @param timeinterval: image stack acquisition time interval (in seconds)
% @param colorofcurve: color for plotting ROI profile, e.g. 'magenta'
% 
% @syntax OS_plot_1c_3d(intensity(1:400,3),'name',3,'r');
% 
% @version 2023/02/26 XJ
%   added documentation and comments; improved style and readability;
%   removed redundancies
% 
% @log
%   2020/4/18， mw to plot t vs. T+n vs. T+ 2n
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================

    %% Initialization
    savedir = [cd '/0analysis'];
    warning off MATLAB:MKDIR:DirectoryExists
    warning('off', 'Images:initSize:adjustingMag');

    %% set up trajectory
    n=3; % 1 sec or 2 sec is too short. 8 sec too long
    
    ROI_profile=double(ROI_profile);
    ll=length(ROI_profile);
    yy = interp1([timeinterval: timeinterval: timeinterval*ll],...
        ROI_profile,[1: 1: timeinterval*ll]);
    ll=length(yy);
    
    %% plot raw profile
    warning('off', 'Images:initSize:adjustingMag');
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4)*0.8 scrsz(3)*0.3 scrsz(4)*0.3],...
        'PaperPosition',[1 12 6 4]);
    tiledlayout(1,2)
    LineW=0.3;
    
    % Left plot
    ax1 = nexttile;
    plot3(yy(1:ll-2*n),yy(1+n:ll-n),yy(1+2*n:ll),'Color',...
        colorofcurve,'LineWidth',LineW);
    xlabel('I');
    ylabel('I+n');
    zlabel('I+2n');
    axis equal
    title(ax1,['n=' num2str(n)])
    set(gca,'xticklabel',{[]},'yticklabel',{[]},'zticklabel',{[]},...
        'XGrid','on','YGrid','on','ZGrid','on');
    
    % Right plot, double n
    n=2*n;
    ax2 = nexttile;
    plot3(yy(1:ll-2*n),yy(1+n:ll-n),yy(1+2*n:ll),'Color',...
        colorofcurve,'LineWidth',LineW);
    xlabel('I');
    ylabel('I+n');
    zlabel('I+2n');
    axis equal
    set(gca,'xticklabel',{[]},'yticklabel',{[]},'zticklabel',{[]},...
        'XGrid','on','YGrid','on','ZGrid','on');
    title(ax2,['n=' num2str(n)])
    
    %% save plot
    cd(savedir);
    saveas(gca, [name '_1c_3d.png']);
    % uncomment below to save as .eps image
    % print('-depsc','-r300', [name '_1c_3d.eps']);
    cd('..');

