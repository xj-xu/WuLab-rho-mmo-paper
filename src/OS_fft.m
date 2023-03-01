function stat=OS_fft(ROI_profile,name,timeinterval,colorofcurve)
% =========================================================================
% Performs a discrete fast fourier transform of the input oscillatory
% signal to identify dominant periods.
%
% ------
% @param  ROI_profile: time series array of ROI intensities
% @param name: name of experiment and ROI number
% @param timeinterval: image stack acquisition time interval (in seconds)
% @param colorofcurve: color for plotting ROI profile, e.g. 'magenta'
% 
% @return stat: period length of the main peak
% 
% @version 2023/02/28 XJ major edits
%   added documentation and comments; improved style and readability;
%   removed redundancies; changed to more intuitive variable names; 
% 
% @log
%   2022/6/4, mw: fixed output (is now correct), minor cosmetic updates, 
%               plot size/xtick, save results in mat, removed polyfit,
%   2022/04/26 jk, copied from fft1d_2peaks2 to use with other OS codes
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================

    %% Initialization
    % input traces
    ROI_profile=ROI_profile(~isnan(ROI_profile));
    ROI_profile=double(ROI_profile);
    ll=length(ROI_profile);
    % define variables suitable for Rho waves
    periodlimit = 300;
    tick_interval=100;
    xmin = 0;
    xmax = periodlimit;
    ymin = 0;
    ymax = 1.5;
    scrsz = get(0,'ScreenSize');
    radius = 3;
    % directory for saving plots
    savedir = [cd '/0analysis'];
    warning off MATLAB:MKDIR:DirectoryExists
    warning('off', 'Images:initSize:adjustingMag');
    mkdir(savedir);
    
    %% Process signal
    % use hanning filter to reduce spectral leakage
    t=timeinterval:timeinterval:ll*timeinterval;
    hanning = 0.5 - 0.5*cos(2*pi*t/t(end));
    ROI_profile= ROI_profile.*hanning';
    % normalize the data
    profile_ordered=sort(ROI_profile);
    profile_min=mean(profile_ordered(1:10));
    profile_max=mean(profile_ordered(ll-1:ll));
    ROI_profile=(ROI_profile-profile_min)/(profile_max-profile_min);
    
    %% FFT
    % Padding would be added for ROI_profiles less than n-points
    n=2048; % will need to changed for longer ROI_profiles
    Y = fft(ROI_profile,n);
    P = Y.*conj(Y) / n;
    power = P(1:n/2 + 1);
    power(2:n/2) = 2*power(2:n/2);
    lengthlimit=length(power);
    nyquist = 1/2; % not the true Nyquist frequency
    freq = (0:ceil(n/2))/(ceil(n/2))*nyquist;
    period=1./double(freq);
    % to eliminate low freq by imposing freq > timeinterval/periodlimit
    ind_filterfreq = find(freq>timeinterval/periodlimit);
    firstindexf = ind_filterfreq(1);
    index_lessthan100=find(period*timeinterval<periodlimit);
    firstindex=index_lessthan100(1);
    
    %% Begin plotting and then hold on
    figure('Position',[scrsz(3)*0.1 scrsz(4)*0.2 ...
        scrsz(3)*0.2 scrsz(4)*0.3],'PaperPosition',[0.25 2.5 2.0 2.0]);
    plot(period*timeinterval,power,'Color',colorofcurve,'LineWidth',0.5);
    xlabel('Period (s)','FontSize', 10);
    ylabel('Power','FontSize', 10);
    set(gca,'XLim',[xmin,xmax]);
    set(gca,'Xtick',[0:tick_interval:500]);
    set(gca,'YTick'); %,nan
    hold on;
    
    %% Find peaks
    allpeaks = zeros(length(firstindex:lengthlimit-radius));
    for iii=firstindex:lengthlimit-radius
        product=1;
        for jjj=1:radius*2+1
            product=product*(power(iii)>=power((iii-radius-1+jjj)));
        end
        allpeaks(iii-firstindex+1)=product;
    end
    % listing of all the power peaks
    allpeaksindex=find (allpeaks==1)+firstindex-1;
    % total area under power curve excluding low freq
    areaP = trapz(freq(firstindexf:lengthlimit),...
        power(firstindexf:lengthlimit)); 
    % find large enough peaks with 0.02 of max criteria
    hh = power(allpeaksindex)>0.02*max(power(firstindex:lengthlimit)); 
    largepeaksindex=allpeaksindex(hh);
    [~,IX] = sort(power(largepeaksindex),'descend');
    index=largepeaksindex(IX);
    
    %% Find valleys
    dP = gradient(power);
    %define peak by valleys
    valleyIndex = [1; find(dP(1:end-1)<0 & dP(2:end)>0)]; 
    stat=round(period(index(1))*timeinterval*10)/10;
    
    %% Overplot the top 5 peaks on the figure
    for j=1:min(length(index),5)
        mainPeriodStr=[num2str(stat) ' s'];
        % find valley/boundary for each peak
        [~,sortedValleys] = sort(abs(freq(valleyIndex)-freq(index(j))));
        f1 = min(valleyIndex(sortedValleys(1:2)));
        f2 = max(valleyIndex(sortedValleys(1:2)));
        peaks(j, 1:3) = [freq(index(j)) period(index(j)) *...
            timeinterval power(index(j))'];
        peaks(j, 4) = 100*trapz(freq(f1:f2),power(f1:f2))/areaP;
        RelativepowerStr=[num2str(round(peaks(j,4)*10)/10),'%'];
        if j==1 % plot major peak
            plot(period(index(j))*timeinterval,power(index(j)),...
                'k.', 'MarkerSize',20);
            title(RelativepowerStr,'FontSize', 10);
            text(period(index(j))*timeinterval+5,power(index(j)),...
                mainPeriodStr,'FontSize', 10);      
        else  % plot minor peaks
            plot(period(index(j))*timeinterval,power(index(j)),...
                '.','Color','k', 'MarkerSize',10);
        end
        set(gcf, 'Color','w');
        hold on;
    end

    %% Finish and save plot
    hold off;
    cd(savedir);
    % print('-depsc','-r150', [name '_fft.eps']);
    saveas(gca,[name '_fft.png']);
    cd('..');
    
    %% uncomment below to display FFT info and save as .mat file
%     peaks = sortrows(peaks, 4, 'descend');
%     save([name '_fft.mat'], 'peaks');
%     T = array2table(peaks,'VariableNames',{'Freq','Period','Power','%'});
%     disp(T)

    close all



