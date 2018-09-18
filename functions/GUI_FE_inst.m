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

% check elapsed time
GUI.FE_timestart = toc(timer_obj.inst_make_fe.UserData);
% disp(GUI.FE_timestart);
if strcmp(exp_inform.exp_mode,'test_mode')
 % instruction of test
GUI.handles.edit_insturction.String = ...
    sprintf('DESIRED OUTPUT: %s',...
    exp_inform.name_FE{exp_inform.order_fe4GUI(exp_inform.i_trl)});   
else
% instruction of training
GUI.handles.edit_insturction.String = ...
    sprintf('MAKE %s FACE FOR 3 s',...
    exp_inform.name_FE{exp_inform.order_fe4GUI(exp_inform.i_trl)});
end
% pic of facial expression  apears in the facial expression list
for i_fe=1:exp_inform.n_fe
    GUI.h_image(i_fe).Visible='off';
end
GUI.h_image(exp_inform.order_fe4GUI(exp_inform.i_trl)).Visible = 'on';

exp_inform.saving_feat=1;
end