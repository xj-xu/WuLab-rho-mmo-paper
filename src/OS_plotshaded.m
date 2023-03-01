function OS_plotshaded(x,y,fstr)
% =========================================================================
% Created shaded standard deviation region in align peaks plot
%
% ------
% @param x: x coordinates
% @param y: either just one y vector, or 2xN or 3xN matrix of y-data
% @param fstr: format ('r' or 'b--' etc)
% 
% @syntax
%   x=[-10:.1:10];
%   plotshaded(x,[sin(x.*1.1)+1;sin(x*.9)-1],'r');
% 
% @version 2023/02/28 XJ
%   added documentation and stylistic adjustments; 
%   removed redundant output varargout
% 
% @log
%   2022/6/4 mw: 
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================
 
    if size(y,1)>size(y,2)
        y=y';
    end;
     
    if size(y,1)==1 % just plot one line
        plot(x,y,fstr);
    end;
     
    if size(y,1)==2 %plot shaded area
        px=[x,fliplr(x)]; % make closed patch
        py=[y(1,:), fliplr(y(2,:))];
        patch(px,py,1,'FaceColor',fstr,'EdgeColor','none');
    end;
     
    if size(y,1)==3 % also draw mean
        px=[x,fliplr(x)];
        py=[y(1,:), fliplr(y(3,:))];
        patch(px,py,1,'FaceColor',fstr,'EdgeColor','none');
        plot(x,y(2,:),fstr);
    end;
     
    alpha(.2); % make patch transparent
