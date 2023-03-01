function stat = OS_alignpeaks_2c(ROI_profile,ROI_profile2,...
    name,timeinterval,xlimit,color1,color2)
% =========================================================================
% Aligns the peaks of two ROI profiles to show their phase relations.
%
% ------
% @param  ROI_profile: time series array of ROI intensities
% @param  ROI_profile2: second time series with same dim as ROI_profile
% @param name: name of experiment and ROI number
% @param timeinterval: image stack acquisition time interval (in seconds)
% @param color1: color for plotting ROI profile1, e.g. 'magenta'
% @param color2: color for plotting ROI profile2
% 
% @return stat: arrray with 6 numbers characterizing the peaks
% 
% @version 2023/02/28 XJ major edits
%   added documentation and comments; improved style and readability;
%   removed name '_ap__' num2str(minpeakheight) and other unused plot
% 
% @log
%   2022/6/4 mw: 
%           fixed bugs:if locs(i)-hp >0 && locs(i)+hp < length(ROInorml1)
%           minor cosmetic updates, plot size/xtick, diplay as a table
%   2022/5/3 Min to be included in the package
%           add calculation of rise/drop/valley duration
%   20141108 YY alignpeaks and do shaded plot for 2 channels versions
%           strategys used in this method:
%           import a .mat file of ROI intensity and align peaks for each 
%           ROI together, then shaded the area of std, plot average curve.
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================

    %% Initialization
    % input traces
    ROInum=length(ROI_profile(1,:));
    ROI_profile=ROI_profile(~isnan(ROI_profile));
    ROI_profile2=ROI_profile2(~isnan(ROI_profile2));
    ll=length(ROI_profile);
    [v]=(0:ll); %ll+1 length
    for i=1:ll
        t(i)=v(i)*timeinterval;
    end
    % parameters optimized Rho oscillations
    minpkdis = round(20/timeinterval);
    minpeakheight = 0.3; % depends on how noisy the data is
    smoothspan=4;
    hp=ceil(xlimit/timeinterval);
    resampling=timeinterval;
    stat=zeros(6,1);
    scrsz = get(0,'ScreenSize');
    % directory for saving plots
    savedir = [cd '/0analysis'];
    warning off MATLAB:MKDIR:DirectoryExists
    warning('off', 'Images:initSize:adjustingMag');
    mkdir(savedir);

    %% Find peaks of each column (ROI)
    for k=1:ROInum
        %channel 1
        ROIintensity_s1(:,k)=smooth(ROI_profile(:,k),smoothspan);
        ROInorml1(:,k)=(ROIintensity_s1(:,k)-min(ROIintensity_s1(:,k)))...
            /(max(ROIintensity_s1(:,k))-min(ROIintensity_s1(:,k)));
        %channel 2
        ROIintensity_s2(:,k)=smooth(ROI_profile2(:,k),smoothspan);
        ROInorml2(:,k)=(ROIintensity_s2(:,k)-min(ROIintensity_s2(:,k)))...
            /(max(ROIintensity_s2(:,k))-min(ROIintensity_s2(:,k)));
        %find peaks based on channel 1
        [pks,locs]=findpeaks(ROInorml1(:,k),'minpeakdistance',...
            minpkdis,'minpeakheight', minpeakheight);
        num_pks=length(locs);
        % output image of peak identification (used smoothed line)
        FigWidth = (0.3375*2)+ ((((timeinterval*ll)/60)/10) *2);
        figure('Position',[1 scrsz(4)*0.8 scrsz(3)*0.6 scrsz(4)*0.2],...
            'PaperPosition',[1 12 FigWidth 1]);
        plot(v(2:ll+1),ROInorml1(:,k),'Color','g','LineWidth',0.5);
        hold on;
        plot(v(2:ll+1),ROInorml2(:,k),'Color','m','LineWidth',0.5);
        plot(locs,pks,'+','Color','b','MarkerSize',10);
        hold off;
        
        %% align peaks
        if num_pks>3 % means require a minimal of 4 peaks
            count=0;
            figure('Position',[scrsz(3)*0.8 scrsz(4)*0.2 ...
                scrsz(3)*0.2 scrsz(4)*0.3],...
                'PaperPosition',[0.25 2.5 2.0 2.0]);
            for i=1:num_pks
                if locs(i)-hp >0 && locs(i)+hp < length(ROInorml1)
                    count=count+1;
                    ROIpks1(:,count)=ROInorml1((locs(i)-hp):locs(i)+hp,k);
                    ROIpks2(:,count)=ROInorml2((locs(i)-hp):locs(i)+hp,k);
                    plot([fliplr((-1)*t(2:(hp+1))),t(1:(hp+1))],...
                        ROIpks1(:,count),'-o','Color',color1,...
                        'LineWidth',1,'MarkerSize',3);%red
                    hold on;
                    plot([fliplr((-1)*t(2:(hp+1))),t(1:(hp+1))],...
                        ROIpks2(:,count),'-o','Color',color2,...
                        'LineWidth',1,'MarkerSize',3)
                end
            end
            hold off;
            
            %% calculate mean and std and start plot
            stdpeaks1=std(ROIpks1');
            meanpeaks1=mean(ROIpks1');
            stdpeaks2=std(ROIpks2');
            meanpeaks2=mean(ROIpks2');
            xxx=[fliplr((-1)*t(2:(hp+1))),t(1:(hp+1))];
            plot([fliplr((-1)*t(2:(hp+1))),t(1:(hp+1))],meanpeaks1,...
                '-','Color',color1,'LineWidth',1,'MarkerSize',3);
            hold on;
            plot([fliplr((-1)*t(2:(hp+1))),t(1:(hp+1))],meanpeaks2,...
                '-','Color',color2,'LineWidth',1,'MarkerSize',3);
            
            %% shade standard deviation area
            x=[fliplr((-1)*t(2:(hp+1))),t(1:(hp+1))];
            y1=[meanpeaks1-stdpeaks1;meanpeaks1+stdpeaks1];
            y2=[meanpeaks2-stdpeaks2;meanpeaks2+stdpeaks2];
            fstr1=color1;
            fstr2=color2;
            OS_plotshaded(x,y1,fstr1);
            alpha(.1);
            OS_plotshaded(x,y2,fstr2);
            alpha(.1);
            
            %% finish and save plot
            labels = {'-100', [],[],[],[], '0', [], [],[], [], '100'};
            set(gca,'XLim',[-100 100],'YLim',[0 1.2],'XTick',[-100 :20: 100],'XTickLabel',labels, 'FontSize',10,'XGrid' , 'on');
            xlabel('Time (s)');
            ylabel('Relative Intensity');
            cd(savedir);
            saveas(gca, [name '_ap_' num2str(minpeakheight) '.png']);
%             print('-depsc','-r300', [name '_ap_' num2str(minpeakheight) '.eps']);
            cd('..');
            
            %% Find rise and drop points
            ty=[-xlimit:1:xlimit]; % resample to every 1 sec
            % linear will result in multiple point with the same slope
            trace=interp1(x,meanpeaks1',ty,'spline');
            trace1_d1 = gradient(trace);
            ll=length(trace1_d1);
            % find the highest slope in the first half of the curve
            rise=find(trace1_d1==max(trace1_d1(round(xlimit/2):xlimit))); 
            peak=find(trace==max(trace));
            % find drop point (same intensity as rise)
            idx=find(trace(1:ll-1)>trace(rise(k)) & ...
                trace(2:ll)<trace(rise(k)));
            idx2=find(idx>xlimit & idx<xlimit*1.5);
            drop=idx(idx2(1));
            % find half-maximal rise point
            half_max=(max(trace)+min(trace))/2;
            idx=find(trace(1:ll-1)<half_max & trace(2:ll)>half_max);
            idx2=find(idx<xlimit & idx>xlimit*1/3);
            rise_half=idx(idx2(length(idx2))); %last one is cloest to peak
            % find half-maximal drop point
            idx=find(trace(1:ll-1)>half_max & trace(2:ll)<half_max);
            idx2=find(idx>xlimit & idx<xlimit*2);
            drop_half=idx(idx2(1));
            % find valley
            valleyIndex = find(trace1_d1(1:ll-1)<0 & trace1_d1(2:ll)>0);
            % find index after peak
            idx2_valley=find(valleyIndex>xlimit & valleyIndex<xlimit*2 );
            if length(idx2_valley)<1
                valley=ll;
            else
                valley=valleyIndex(idx2_valley(1));
            end
            % find index before peak
            idx2_v2=find(valleyIndex<xlimit & valleyIndex>xlimit*1/3 );
            if length(idx2_v2)<1
                v2=1;
            else
                v2=valleyIndex(idx2_v2(length(idx2_v2)));
            end
            % add dots
            hold on;
            plot(ty(rise),trace(rise),'.','Color',[0.7 0.7 0.7],...
                'MarkerSize',5); % plot the dot
            text(ty(rise)-20,trace(rise),num2str(peak-rise),'FontSize', 6);
            hold on
            plot(ty(drop),trace(drop),'.','Color',[0.7 0.7 0.7],...
                'MarkerSize',5); % plot the dot
            text(ty(drop)+3,trace(drop),num2str(drop-peak),'FontSize', 6);
            hold on;
            plot(ty(rise_half),trace(rise_half),'g.', 'MarkerSize',5);
            text(ty(rise_half)-20,trace(rise_half),...
                num2str(peak-rise_half),'FontSize', 6);
            hold on
            plot(ty(drop_half),trace(drop_half),'g.', 'MarkerSize',5);
            text(ty(drop_half)+3,trace(drop_half),...
                num2str(drop_half-peak),'FontSize', 6);
            hold on
            plot(ty(valley),trace(valley),'.','Color',[0.7 0.7 0.7],...
                'MarkerSize',5); % plot the dot
            if valley<ll
                text(ty(valley)-5,trace(valley)+0.1,...
                    num2str(valley-peak),'FontSize', 6);
            end
            hold on
            plot(ty(v2),trace(v2),'.','Color',[0.7 0.7 0.7],...
                'MarkerSize',5); % plot the dot
            if valley<ll
                text(ty(v2)-5,trace(v2)+0.1,num2str(peak-v2),...
                    'FontSize', 6);
            end
            hold off;
            % save the version with dot highlighted
            cd(savedir);
            saveas(gca, [name '_ap_d_' num2str(minpeakheight) '.png']);
            % print('-depsc','-r300', [name '_ap_d_' ...
            %   num2str(minpeakheight) '.eps']);
            cd('..');

            %% uncomment below to display and save results in .mat
%             % display results
%             T = array2table([stat(1:2:5), stat(2:2:6)],...
%                 'VariableNames',{'aligned peaks:Rise','Drop'},'RowName',...
%                 {'by derivitive','by half-point','peak to valley'});
%             disp(T)
%             % save all parameters as a mat file
%             cd(savedir);
%             save([name '_shadedplot_2cl.mat'],'stat','meanpeaks1','stdpeaks1',...
%                 'meanpeaks2','stdpeaks2','timeinterval','color1','color2');
%             cd('..');

            %% return stat
            stat(1)=peak-rise;
            stat(2)=drop-peak;
            stat(3)=peak-rise_half;
            stat(4)=drop_half-peak;
            stat(5)=peak-v2;
            stat(6)=valley-peak;

        end
    end

    close all
