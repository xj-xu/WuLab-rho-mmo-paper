function OS_plot_1c(ROI_profile,name,timeinterval,colorofcurve)
% =========================================================================
% Plots the input intensity profile over time.
% In most cases, each value plotted is the fluorescence intensity 
% averaged over the pixels contained in the ROI (e.g. 3x3 uM).
% 
% ------
% @param  ROI_profile: time series array of ROI intensities
% @param name: name of experiment and ROI number
% @param timeinterval: image stack acquisition time interval (in seconds)
% @param colorofcurve: color for plotting ROI profile, e.g. 'magenta'
% 
% @syntax OS_plot_1c(intensity(1:400,3),'name',3,'r');
% 
% @version 2023/02/26 XJ
%   added documentation and comments; improved style and readability;
%   removed redundancies
%   changed raw plot labels and removed cropped plots
% 
% @log
%   2022/4/9， mw to set up standard code to streamline analysis. 
%           copied from Matlab/Ding and split fft1d_2peaks2.m 
%           to OS_1plot_w_adjusted.m and OS_2fft.m, 
%   2022/4/18, mw minor update, timeaxis start from 0. 
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
    
    %% plot raw profile
    ROI_profile=double(ROI_profile);
    ll=length(ROI_profile);
    timeaxis=(0:timeinterval:(ll-1)*timeinterval)/60;
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4)*0.8 scrsz(3)*0.3 scrsz(4)*0.3],...
        'PaperPosition',[1 12 3.6 2]);
    plot(timeaxis,ROI_profile,'Color',colorofcurve,'LineWidth',0.7);
    set(gca,'XTick',0:5:round(ll*timeinterval*10/60)/10,'XGrid','on',...
        'YLim',[min(ROI_profile) max(ROI_profile)]);
    xlabel('Time (mins)');
    ylabel('Raw intensity');
    set(gca,'XLim',[0 round(ll*timeinterval*10/60)/10]);
    
    %% save plot
    cd(savedir);
    saveas(gca, [name '_plot_1c_raw.png']); 
    % uncomment below to save as .eps image
    % print('-depsc','-r300', [name '_raw.eps']); 
    cd('..');

