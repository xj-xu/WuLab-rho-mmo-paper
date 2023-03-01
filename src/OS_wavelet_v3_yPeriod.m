function OS_wavelet_v3_yPeriod(ROI_profile,name,timeinterval)
% =========================================================================
% Performs a wavlet transform and plots the power spectrum of the period
% over time.
% 
% ------
% @param  ROI_profile: time series array of ROI intensities
% @param name: name of experiment and ROI number
% @param timeinterval: image stack acquisition time interval (in seconds)
% 
% @version 2023/02/26 XJ
%   added documentation and comments; improved style and readability;
%   removed redundancies
% 
% @log
%   22/4/9 MW: version 3 written as function OS_wavelet_v3_yPeriod.m
%   19/8/14 MW: to test wavelet analysis with long-term oscillation data
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================

    %% Initialization
    X=ROI_profile(~isnan(ROI_profile));
    ll=length(X);
    time=timeinterval:timeinterval:ll*timeinterval;
    % directory for saving plots
    savedir = [cd '/0analysis'];
    warning off MATLAB:MKDIR:DirectoryExists
    warning('off', 'Images:initSize:adjustingMag');
    mkdir(savedir);
    
    %% Plot trace with wavelet power spectrum
    % cwt() returns the scale-to-frequency conversions f in hertz
    % cfs here has been converted to cycles/min
    % sampling frequency is acquisition interval converted to cycles/min
    [cfs, period] = cwt(X, minutes(timeinterval/60));
    figure
    subplot(2,1,1)
    plot(time/60,X)
    axis tight
    xlabel('Time (min)')
    ylabel('Amplitude')
    subplot(2,1,2)
    surface(time/60,period,abs(cfs))
    axis tight
    ylim([minutes(0.11) minutes(5)]) 
    shading flat
    colormap jet;
    xlabel('Time (min)')
    ylabel('Period (min)')
    % save figure
    cd(savedir);
    % print('-depsc','-r150', [name '_wavelet.eps']);
    saveas(gca, [name '_wavelet.png']);
    cd('..');
    
    close all
