%--------------------------------------------------------------------------
% Visualization of EMG real-time signal 
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function onPaint(  )
global GUI;
global exp_inform;
global cq;
% global id_emg_onset;

try
    
%--------------------------EMG onset plot---------------------------------%
% temp_emg_onset = cq.emg_onset.data(1:cq.emg_onset.datasize,:);
% temp_emg_onset(temp_emg_onset==0) = NaN;
%-------------------------------------------------------------------------%
%%draw second axes
%data_tmp = cq.emg_procc.data;szProcessedData

if cq.emg_procc.datasize<=0
    return;
end

data_tmp = cq.emg_procc.data(1:cq.emg_procc.datasize,:);
baseline = -data_tmp(1,:);
for i = 1 : exp_inform.n_bip_ch
    if isnan(baseline(i))
        baseline(:,i) = 0;
    end
end
offset = 100;
for i= 1 : exp_inform.n_bip_ch 
    baseline(i) = baseline(i) - (i-1)*offset;
    data_tmp(:,i) = data_tmp(:,i)+baseline(i);
%     temp_emg_onset(:,i) = temp_emg_onset(:,i)*baseline(i);
end
% myStop;
plot(GUI.handles.axes1, data_tmp); 
hold(GUI.handles.axes1,'on');
% stairs(GUI.handles.axes1,temp_emg_onset,'r','LineWidth',2);

xlim(GUI.handles.axes1, [0 exp_inform.length_buff]);
line([cq.emg_procc.index_end, cq.emg_procc.index_end],...
    get(GUI.handles.axes1,'ylim'),'parent',GUI.handles.axes1);

%label ����
set(GUI.handles.axes1,'xtick',0:exp_inform.sf:exp_inform.period_buff*exp_inform.sf);
szXTicks = cell(1,exp_inform.period_buff+1);
for i= 1 : exp_inform.period_buff
    szXTicks{i} = char('0' + i-1);
end
szXTicks{11} = char('10');
set(GUI.handles.axes1,'xticklabel',szXTicks);
drawnow;

hold(GUI.handles.axes1,'off');

catch ex
    struct2cell(ex.stack)'
    myStop;
    keyboard;
end