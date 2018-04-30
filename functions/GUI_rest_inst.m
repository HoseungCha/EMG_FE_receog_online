%--------------------------------------------------------------------------
% Rest instruction GUI code
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function GUI_rest_inst()
global timer_obj
global exp_inform;
global GUI;
global DB_backup;
global path;
try
    %% GUI Rest, time check
    GUI.FE_timestart = toc(timer_obj.inst_make_fe.UserData);
    GUI.rest_timestart = toc(timer_obj.inst_rest.UserData);
    disp(GUI.rest_timestart);
    
    %% presentation of facial expression pic.
    for i_fe=1:exp_inform.n_fe
        GUI.h_image(i_fe).Visible='off';
    end
%     myStop;
    GUI.h_image(GUI.idx_defalt_img).Visible = 'on';
    
    %% instruction of resting
    GUI.handles.edit_insturction.String = ...
        sprintf('Please release the tension in your face');
    %% when finished
    if(GUI.id_end_fe)
        if GUI.handles.radiobutton_train.Value == 1 % when train finished
            GUI.handles.edit_insturction.String = ...
                sprintf('Registeration is being conducted. please wait.');
            myStop(); % timer ����
            %             closePreview(info.cam); % cam ����
            find_feat_and_train(); %% train LDA%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        elseif GUI.handles.radiobutton_test.Value == 1% when test finished
            GUI.handles.edit_insturction.String = ...
                sprintf('A session has been finished.');
            fprintf('A session has been finished.');
            myStop;
            DB_backup.test_result;
            uisave({'DB_backup','exp_inform'},fullfile(path.code,'DB','DB_online',...
            datestr(now,'yymmdd_te_'))); % saving results
        end
    end
    
catch ex
    struct2cell(ex.stack)'
    myStop;
    keyboard;
end
end