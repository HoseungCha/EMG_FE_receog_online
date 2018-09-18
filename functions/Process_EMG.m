%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
% process EMG 함수

function Process_EMG()
global GUI;
global exp_inform;
global cq;
global id_emg_onset;
try

% get elapsed time using tic toc
% timeStart = toc(info.timer.process_emg.UserData);  %for debugging
% myStop;
% get emg segment
curr_win =cq.emg_procc.getLastN(exp_inform.sf_of_timer);

%========================feat extracion===================================%
temp_rms = sqrt(mean(curr_win.^2)); % RMS



% other features extracion
temp_CC = featCC(curr_win,4); % CC
temp_WL = sum(abs(diff(curr_win,2))); % WL
temp_SampEN = SamplEN(curr_win,2); % Sample EN

% feat concatinating
temp_feat = zeros(1,28);
temp_feat(1:4) = temp_rms;
temp_feat(5:8) = temp_WL;
temp_feat(9:12) = temp_SampEN;
temp_feat(13:end) = temp_CC;

%=========================================================================%

%=========================emg onset detection=============================%
% id_emg_onset = zeros(1,exp_inform.n_bip_ch);
% for i_ch = 1 : exp_inform.n_bip_ch
%     id_emg_onset(i_ch) = ...
%         predict(exp_inform.model.model_tree_emg_onset,temp_rms(i_ch));
% end
% cq.emg_onset4mv.add(id_emg_onset);
%=========================================================================%
%=============SAVE FEATURES with insturction(or triggers)=================%
% exp_inform.saving_feat
if(GUI.id_start_fe==1&&exp_inform.saving_feat==1)
    % inqueue of feature extracted during 3 s 
    cq.featset.addArray(temp_feat);

    if cq.featset.datasize == cq.featset.length  
%         myStop;
        disp(exp_inform.i_trl);
        
        exp_inform.FeatSet{exp_inform.i_trl} = cq.featset.data;
        disp(exp_inform.FeatSet);
        
        if isempty(exp_inform.FeatSet{exp_inform.i_trl})
            keyboard;
        end

        % feature buffer init
        cq.featset = circlequeue(exp_inform.n_win,...
            exp_inform.n_bip_ch*3+exp_inform.n_bip_ch*4);

        % for FE GUI
        GUI.id_start_fe = 0;

        % go next facial expression
%         myStop;
        exp_inform.i_trl = exp_inform.i_trl +1;
        disp(exp_inform.i_trl);
        
    end
end
%=========================================================================%

%+++++++++++++++++++++++++++test mode+++++++++++++++++++++++++++++++++++++%
if GUI.handles.radiobutton_test.Value
    
    % classification of each emotion
    y_corrected = conditonal_voting_online(temp_feat,...
        exp_inform.model.FE_emotion,exp_inform.template_c3);
%     y_corrected = 9;
%     disp(y_corrected);
    if isnan(y_corrected)
        return;
    end

    GUI.handles.edit_classification.String = ...
        sprintf('Emotion: %s',...
        exp_inform.name_FE{y_corrected});

    %------------------presentation of avartar----------------------%
    temp_output_eye = exp_inform.name_gesture_clfr{1}{y_corrected};
    temp_output_lip = exp_inform.name_gesture_clfr{2}{y_corrected};
%     myStop;
%     plot_avartar(GUI.handles.axes_avartar,temp_output_eye,...
%         'neutral',temp_output_lip);
    fprintf('%s %s\n',temp_output_eye,temp_output_lip);
%     drawnow;
    %---------------------------------------------------------------%
    
%     myStop;
    
% exp_inform.udp
    %------do UDP control  to control avartar-------------%
    fprintf(exp_inform.udp,temp_output_eye);
    fprintf(exp_inform.udp,temp_output_lip);
    %-------------------------------------------------------------%
%     disp(exp_inform.name_FE{y_corrected});

    %------do serial communication to control avartar-------------%
    %             fprintf(exp_inform.PC_serial, num2str(fp));
    %-------------------------------------------------------------%
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

%==================WHEN EXPERIMENT IS FINISHED======================%
% you should not confuse the trial has to be more 1,becasue the last trial
% should be proccessed
 % 11번째까지 다마치고 12번째로 바뀔 때가 끝임
if (exp_inform.i_trl == 12)
    myStop();
    find_feat_and_train(); % get LDA mode save it with DB
end
%=========================================================================%

catch ex
disp(struct2cell(ex.stack)');
myStop;
keyboard;
end
end


function f = featCC(curwin,order)
cur_xlpc = real(lpc(curwin,order)');
cur_xlpc = cur_xlpc(2:(order+1),:);
Nsignals = size(curwin,2);
cur_CC = zeros(order,Nsignals);
for i_sig = 1 : Nsignals
    cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order,order)';
end
f = reshape(cur_CC,[1,order*Nsignals]);
end

function c=a2c(a,p,cp)
%Function A2C: Computation of cepstral coeficients from AR coeficients.
%
%Usage: c=a2c(a,p,cp);
%   a   - vector of AR coefficients ( without a[0] = 1 )
%   p   - order of AR  model ( number of coefficients without a[0] )
%   c   - vector of cepstral coefficients (without c[0] )
%   cp  - order of cepstral model ( number of coefficients without c[0] )

%                              Made by PP
%                             CVUT FEL K331
%                           Last change 11-02-99

c = NaN(cp,1);
for n=1:cp
    sum=0;
    if n<p+1
        for k=1:n-1
            sum=sum+(n-k)*c(n-k)*a(k);
        end
        c(n)=-a(n)-sum/n;
    else
        for k=1:p
            sum=sum+(n-k)*c(n-k)*a(k);
        end
        c(n)=-sum/n;
    end
end
end

function f = SamplEN(curwin,dim)
N_sig = size(curwin,2);
f = zeros(1,N_sig);
R = 0.2*std(curwin);
for i_sig = 1 : N_sig
    f(i_sig) = sampleEntropy(curwin(:,i_sig), dim, R(i_sig),1); %%   SampEn = sampleEntropy(INPUT, M, R, TAU)
end
end
