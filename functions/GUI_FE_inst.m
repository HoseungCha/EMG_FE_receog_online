%--------------------------------------------------------------------------
% Facial Expression instruction GUI code
%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function GUI_FE_inst()
global timer_obj
global exp_inform;
global GUI;

%     myStop;
    %% GUI Facial expression, time check
    GUI.FE_timestart = toc(timer_obj.inst_make_fe.UserData);
    disp(GUI.FE_timestart);
    
    %% presentation of facial expression pic.
    for i_fe=1:exp_inform.n_fe
        GUI.h_image(i_fe).Visible='off';
    end
    GUI.h_image(exp_inform.order_fe4GUI(1)).Visible = 'on';
            
    %% instruction of training
%     myStop;
    GUI.handles.edit_insturction.String = ...
        sprintf('Please make a %s face for 3 seconds',...
        exp_inform.name_FE{exp_inform.order_fe4GUI(1)});
    
    %% go next facial expression 
    exp_inform.order_fe4GUI = circshift(exp_inform.order_fe4GUI,-1 ,2);
    
    %% when finsihed
    if isequal(exp_inform.order_fe4GUI,exp_inform.order_fe)
        GUI.id_end_fe = 1; % Facial instuction end signal
    end
    GUI.id_start_fe = 1;
end