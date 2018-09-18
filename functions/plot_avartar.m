%--------------------------------------------------------------------------
% This code is about drawing avartar with facial unit controlled

%==============eye brow control============================%
% One of them should be selected for id_eyebrow 
% neutral
% eye_brow_up
% eye_brow_down
%==========================================================%

%==============zygomaticus control=========================%
% One of them should be selected for id_zygo 
% neutral
% nose_wrinkle
%==========================================================%

%==============lips control================================%
% One of them should be selected for id_lips
% neutral
% lip_corner_up_left
% lip_corner_up_right
% lip_corner_up_both
% clench
% lip_stretch_down
% kiss
% lip_open
% lip_tighten
%==========================================================%
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function plot_avartar(ax,id_eyebrow,id_zygo,id_lips)
%-------------------check the number of input arguments-------------------%
if nargin<1
  ax = [];
end
if nargin<2
  id_eyebrow=[];
end
if nargin<3
  id_zygo=[];
end
if nargin<4
  id_lips=[];
end

% set up the default values

if isempty(id_eyebrow),ax=gca;;end
if isempty(id_eyebrow),id_eyebrow='neutral_e';end
if isempty(id_zygo),id_zygo='neutral';end
if isempty(id_lips),id_lips='neutral_l';end
%-------------------------------------------------------------------------%


%-------------------------add functions-----------------------------------%
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

cla(ax,'reset');
ax.XLim = [-1 1];
ax.YLim = [-1 1];
hold(ax,'on');

%---------------------avartar basic---------------------------------------%
% draw face
ellipse(ax,0.6,0.9,0,0,0,'k');

% draw eyes
xpos_eye_left = -0.3;
ypos_eye = 0.15;
xpos_eye_right = abs(xpos_eye_left);

size_eye_width = 0.2;
size_eye_height = 0.1;
size_pupil = 0.088;

ellipse(ax,size_eye_width,size_eye_height,0,xpos_eye_left,ypos_eye,'k');
ellipse(ax,size_eye_width,size_eye_height,0,xpos_eye_right,ypos_eye,'k');


filledCircle(ax,[xpos_eye_left, ypos_eye],size_pupil,100,'k');
filledCircle(ax,[xpos_eye_right, ypos_eye],size_pupil,100,'k');

% draw nose
ypos_nose = -0.2;
size_nose_width = 0.2;
size_nose_height = 0.2;
pos_nose_top = [0,ypos_nose+size_nose_height/2];
pos_nose_left = [-1*size_nose_height/2,ypos_nose-size_nose_height/2];
pos_nose_right = [abs(pos_nose_left(1)),ypos_nose-size_nose_height/2];

tmp = [pos_nose_left;pos_nose_top;pos_nose_right];
plot(ax,tmp(:,1),tmp(:,2),'k');
tmp = [pos_nose_left;pos_nose_right];
plot(ax,tmp(:,1),tmp(:,2),'k');
%-------------------------------------------------------------------------%


%-----------------------eye brow control----------------------------------%
% setting eye brow
xpos_left_eyebrow = -0.32;
xpos_right_eyebrow = abs(xpos_left_eyebrow);

size_eyebrow_width = 0.4;
ypos_eye_brow = 0.35;
ypos_eye_brow_up = 0.45;

% prepare interpolation of eyebrow left
xq_left = (xpos_left_eyebrow-size_eyebrow_width/2):0.01:...
    (xpos_left_eyebrow+size_eyebrow_width/2);

% prepare interpolation of eyebrow left
xq_right = abs(fliplr(xq_left));

switch id_eyebrow
    case 'neutral_e' % NEUTRAL
        % left eye brow
        tmp = [xpos_left_eyebrow-size_eyebrow_width/2,...
            xpos_left_eyebrow+size_eyebrow_width/2];
        plot(ax,tmp,[ypos_eye_brow, ypos_eye_brow],'k');

        % right eye brow
        plot(ax,abs(fliplr(tmp)),[ypos_eye_brow, ypos_eye_brow],'k');
    
    case 'eye_brow_up' % Eye brow up
        xq = xpos_left_eyebrow-size_eyebrow_width/2:0.01:xpos_left_eyebrow+size_eyebrow_width/2;

        pos_eye_brow_up = interp1([xq(1), mean(xq), xq(end)],...
        [ypos_eye_brow,ypos_eye_brow_up,ypos_eye_brow],xq,'spline');
       
        plot(ax,xq,pos_eye_brow_up,'k')
        plot(ax,sort(abs(xq)),pos_eye_brow_up,'k')
        
        % wrinkles of forehead
        ypos_wrinkle_forehead = 0.6;
        size_wrinkle = 0.3;
        plot(ax,[-1*size_wrinkle/2,size_wrinkle/2],...
            [ypos_wrinkle_forehead,ypos_wrinkle_forehead],'k');
        plot(ax,[-1*size_wrinkle/2,size_wrinkle/2],...
            [ypos_wrinkle_forehead+0.04,ypos_wrinkle_forehead+0.04],'k')
    case 'eye_brow_down' % Eye brow(frown)
        tmp1 = [xpos_left_eyebrow-size_eyebrow_width/2,xpos_left_eyebrow+size_eyebrow_width/2];
        tmp2 = [ypos_eye_brow_up,ypos_eye_brow];
        plot(ax,tmp1,tmp2,'k')  
        plot(ax,abs(fliplr(tmp1)),fliplr(tmp2),'k')
        
        % wrinkles of forehead
        ypos_wrinkle_forehead = 0.3;
        size_wrinkle = 0.1;
        plot(ax,[-0.01,-0.01],...
            [ypos_wrinkle_forehead-1*size_wrinkle/2,...
            ypos_wrinkle_forehead+size_wrinkle/2],'k');
        plot(ax,[0.01,0.01],...
            [ypos_wrinkle_forehead-1*size_wrinkle/2,...
            ypos_wrinkle_forehead+size_wrinkle/2],'k');
    case 'eye_brow_sad' % 
        xq = xpos_left_eyebrow-size_eyebrow_width/2:0.01:xpos_left_eyebrow+size_eyebrow_width/2;

        pos_eye_brow_up = interp1([xq(1), mean(xq), xq(end)],...
        [ypos_eye_brow,ypos_eye_brow,ypos_eye_brow_up],xq,'spline');
       
        plot(ax,xq,pos_eye_brow_up,'k')
        
        xq_right = abs(fliplr(xq));
        pos_eye_brow_up = interp1([xq_right(1), mean(xq_right), xq_right(end)],...
        [ypos_eye_brow_up,ypos_eye_brow,ypos_eye_brow],xq_right,'spline');
    
        plot(ax,xq_right,pos_eye_brow_up,'k')
end
%-------------------------------------------------------------------------%

%------------------------ZYGOMATIC MUSCLE CONTROL-------------------------%
switch id_zygo
    case 'neutral' % NEUTRAL
        % NOTHING
    case 'nose_wrinkle' % NOSE WRINKLE
        % wrinkles of nose
        ypos_wrinkle_forehead = 0;
        size_wrinkle = 0.1;
        plot(ax,[-1*size_wrinkle/2,size_wrinkle/2],...
            [ypos_wrinkle_forehead,ypos_wrinkle_forehead],'k');
        plot(ax,[-1*size_wrinkle/2,size_wrinkle/2],...
            [ypos_wrinkle_forehead+0.04,ypos_wrinkle_forehead+0.04],'k')
end
%-------------------------------------------------------------------------%

%---------------------------LIP SHAPES CONTROL----------------------------%
ypos_lip = -0.6;
size_lip_width = 0.35;
size_lip_height = 0.1;
% lip corner up
ypos_lip_corner_up= -0.5;
xq = -1*size_lip_width/2:0.01:size_lip_width/2;

switch id_lips
    case 'neutral_l' % NEUTRAL
    % draw lips
    plot(ax,[-1*size_lip_width/2,size_lip_width/2],[ypos_lip,ypos_lip],'k');
    
    case 'lip_corner_up_left' % LIP CORNER UP (LEFT)
        ypos_both_lip_corner_up = [ypos_lip_corner_up,ypos_lip,ypos_lip];
        pos_left_lip_corner_up = interp1([xq(1),mean(xq),xq(end)],...
            ypos_both_lip_corner_up,xq,'spline');
        plot(ax,xq,pos_left_lip_corner_up,'k');

    case 'lip_corner_up_right' % LIP CORNER UP (RIGHT)
        ypos_both_lip_corner_up = [ypos_lip_corner_up,ypos_lip,ypos_lip];
        % left lip corner up
        pos_right_lip_corner_up = interp1([xq(1),mean(xq),xq(end)],...
            fliplr(ypos_both_lip_corner_up),xq,'spline');
        plot(ax,xq,pos_right_lip_corner_up,'k')
        
    case 'lip_corner_up_both' % LIP CORNER UP (BOTH)
        % both lip corner up
        ypos_both_lip_corner_up = [ypos_lip_corner_up,...
            ypos_lip,ypos_lip_corner_up];

        pos_right_lip_corner_up = interp1([xq(1),mean(xq),xq(end)],...
            fliplr(ypos_both_lip_corner_up),xq,'spline');
        plot(ax,xq,pos_right_lip_corner_up,'k')
        
    case 'clench' % CLENCH
        
        plot(ax,[-1*size_lip_width/2,size_lip_width/2],...
            [ypos_lip_corner_up - size_lip_height/2,...
            ypos_lip_corner_up - size_lip_height/2],'k');
        
        plot(ax,[-1*size_lip_width/2,size_lip_width/2],...
            [ypos_lip_corner_up + size_lip_height/2,...
            ypos_lip_corner_up + size_lip_height/2],'k');
        
        plot(ax,[-1*size_lip_width/2,-1*size_lip_width/2],...
            [ypos_lip_corner_up + size_lip_height/2,...
            ypos_lip_corner_up - size_lip_height/2],'k');
        
        plot(ax,[size_lip_width/2,size_lip_width/2],...
            [ypos_lip_corner_up + size_lip_height/2,...
            ypos_lip_corner_up - size_lip_height/2],'k');
 
    
    case 'lip_stretch_down' % LIP STRETCH DOWNWARD
        diff = 0.1;

        plot(ax,[-1*size_lip_width/2+diff,size_lip_width/2-diff],...
        [ypos_lip_corner_up + size_lip_height/2,...
        ypos_lip_corner_up + size_lip_height/2],'k');
    
        plot(ax,[-1*size_lip_width/2,size_lip_width/2],...
        [ypos_lip_corner_up - size_lip_height/2,...
        ypos_lip_corner_up - size_lip_height/2],'k');

        plot(ax,[-1*size_lip_width/2+diff,-1*size_lip_width/2],...
        [ypos_lip_corner_up + size_lip_height/2,...
        ypos_lip_corner_up - size_lip_height/2],'k');

        plot(ax,[size_lip_width/2-diff,size_lip_width/2],...
        [ypos_lip_corner_up + size_lip_height/2,...
        ypos_lip_corner_up - size_lip_height/2],'k'); 
    
    case 'kiss' % KISS
        % draw face
        ellipse(ax,size_lip_height,size_lip_height,0,0,ypos_lip,'k');
        ellipse(ax,size_lip_height/2,size_lip_height/2,0,0,ypos_lip,'k');

    case 'lip_open' % O SHAPE( SURPRISED)
        ellipse(ax,size_lip_height,size_lip_height+0.10,0,0,ypos_lip,'k');
        
    case 'lip_tighten' % lip titening
        % draw neutral lips
        plot(ax,[-1*size_lip_width/2,size_lip_width/2],[ypos_lip,ypos_lip],'k');
        
        % draw vertical wrinkles
        pos_2_draw_vertical = [-1*size_lip_width/2,size_lip_width/2]/3;
        
        % size_wrinkle_vertical
        size_wrinkle = 0.1;
        
        % plot wrinkles
        plot(ax,[pos_2_draw_vertical(1),pos_2_draw_vertical(2)],...
        [ypos_lip-size_wrinkle,ypos_lip-size_wrinkle],'k');
    
        plot(ax,[pos_2_draw_vertical(1),pos_2_draw_vertical(2)],...
        [ypos_lip-size_wrinkle/2,ypos_lip-size_wrinkle/2],'k');
    
%         plot([pos_2_draw_vertical(1),pos_2_draw_vertical(2)],...
%         [ypos_lip+size_wrinkle,ypos_lip+size_wrinkle],'k');
%     
%         plot([pos_2_draw_vertical(1),pos_2_draw_vertical(2)],...
%         [ypos_lip+size_wrinkle/2,ypos_lip+size_wrinkle/2],'k');
    
end
%-------------------------------------------------------------------------%
hold(ax,'off');
end






