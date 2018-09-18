%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
% 2017.09.20 main timer function 데이터를 실시간으로 queue로 넣는 코드.
%--------------------------------------------------------------------------
function data_acq_n_preprocessing(  )
global GUI;
global exp_inform;
global p;
global File
global cq
global id_emg_onset;
% timeStart = toc(timer_obj.data_acq_n_preprocessing.UserData)
try
switch GUI.prog_mode
    case 'file_mat'
        if File.curr_pos+exp_inform.sf_of_timer-1 > size(File.raw_data,1)
            myStop();
            return;
        end
        myStop;
        seg = File.raw_data(...
            File.curr_pos:File.curr_pos+exp_inform.sf_of_timer-1,...
            1:File.n_raw_ch-1);
        
        File.curr_pos = File.curr_pos+ exp_inform.sf_of_timer;

    case 'file_bdf'
        if File.curr_pos+exp_inform.sf_of_timer-1 > size(File.raw_data,1)
            myStop();
            return;
        end
        seg = File.raw_data(...
            File.curr_pos:File.curr_pos+exp_inform.sf_of_timer-1,...
            1:File.n_raw_ch);
        
        
        
        % trigger signal
        if File.curr_pos<File.lat_trg_onset(exp_inform.i_trl)...
        &&File.lat_trg_onset(exp_inform.i_trl)<=(File.curr_pos+ exp_inform.sf_of_timer)
            GUI.id_start_fe = 1;
            disp(File.lat_trg_onset);
            disp(File.lat_trg_onset(exp_inform.i_trl));
            disp(exp_inform.i_trl);
        end
        if  GUI.id_start_fe ==1
            GUI_FE_inst();
        else
            GUI_rest_inst();
        end
        File.curr_pos = File.curr_pos+ exp_inform.sf_of_timer;
    case 'online_biosemi'
        seg = biosemi_signal_recieve(exp_inform.n_ch_rawdata);
        GUI.id_start_fe = 1;

    case 'online_biosemi_eprime'
        seg = biosemi_signal_recieve(exp_inform.n_ch_rawdata);
end
% get size of segment
n_seg = size(seg,1);


% check if data were collceted, if it is not, return it
if ~exist('seg','var')
    return;
end

if n_seg == 0
%         myStop;
    return;
end

% except program mode of file_mat, do save rawdata!
if ~strcmp(GUI.prog_mode,'file_mat')
exp_inform.raw_data(exp_inform.raw_pos:exp_inform.raw_pos+n_seg-1,1:exp_inform.n_ch_rawdata)...
    = seg;
if(GUI.id_start_fe)        
    exp_inform.raw_data(exp_inform.raw_pos:exp_inform.raw_pos+n_seg-1,exp_inform.n_ch_rawdata+1)...
        = ones(n_seg,1);
else
    exp_inform.raw_data(exp_inform.raw_pos:exp_inform.raw_pos+n_seg-1,exp_inform.n_ch_rawdata+1)...
        = zeros(n_seg,1);
end
exp_inform.raw_pos = exp_inform.raw_pos + n_seg;
end


% bipolar channel configuration
temp_chan = cell(4,1);

%Right_Zygomaticus
temp_chan{1}= seg(:,exp_inform.idx_pair_right(exp_inform.i_emg_pair,1))...
    - seg(:,exp_inform.idx_pair_right(exp_inform.i_emg_pair,2));
temp_chan{2}= seg(:,4) - seg(:,5); %Right_Frontalis
temp_chan{3}= seg(:,6) - seg(:,7); %Left_Corrugator
temp_chan{4}= seg(:,exp_inform.idx_pair_left(exp_inform.i_emg_pair,1))...
    - seg(:,exp_inform.idx_pair_left(exp_inform.i_emg_pair,2)); %LEFT_Zygomaticus

segs = cat(2,temp_chan{:});


% filtering notch, BPF
if isempty(p.f.nZn)
    [segs,p.f.nZn] = filter(p.f.nB,p.f.nA,...
       segs,[],1);
else
    [segs,p.f.nZn] = filter(p.f.nB,p.f.nA,segs,p.f.nZn,1);
end    
if isempty(p.f.bZn)
    [segs,p.f.bZn] = filter(p.f.bB,p.f.bA,...
        segs,[],1);
else
    [segs,p.f.bZn] = filter(p.f.bB,p.f.bA,segs,p.f.bZn,1);
end

% buffer for plotting
cq.emg_procc.addArray(segs); % 그림 출력 데이터

% EMG signal processing and classification
Process_EMG(); 

% buffer for emg onset
% cq.emg_onset.addArray(repmat(id_emg_onset,n_seg,1));



catch ex
disp(struct2cell(ex.stack)');
myStop;
keyboard;
end
end

