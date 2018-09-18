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

try
    
% check elapsed time
GUI.FE_timestart = toc(timer_obj.inst_make_fe.UserData);
GUI.rest_timestart = toc(timer_obj.inst_rest.UserData);
%     disp(GUI.rest_timestart);

if strcmp(exp_inform.exp_mode,'test_mode')
     % instruction of test
    GUI.handles.edit_insturction.String = ...
        sprintf('TEST MODE');   
else
    % instruction of resting are given
    GUI.handles.edit_insturction.String = ...
        sprintf('RELEASE TENSION IN YOUR FACE');
end
% pic of neutral facial expression  apears 
for i_fe=1:exp_inform.n_fe
    GUI.h_image(i_fe).Visible='off';
end
GUI.h_image(GUI.idx_defalt_img).Visible = 'on';
exp_inform.saving_feat=0; 
catch ex
struct2cell(ex.stack)'
myStop;
keyboard;
end
end