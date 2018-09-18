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

% get emg segment
curr_win =cq.emg_procc.getLastN(exp_inform.sf_of_timer);

%========================feat extracion===================================%
temp_rms = sqrt(mean(curr_win.^2)); % RMS



% other features extracion
temp_CC = featCC(curr_win,4); % CC
temp_WL = sum(abs(diff(curr_win,2))); % WL
temp_SampEN = SamplEN(curr_win,2); % Sample EN

% feat concatinating
temp_feat = [temp_rms,temp_WL,temp_SampEN,temp_CC];
%=========================================================================%

%=========================emg onset detection=============================%
id_emg_onset = zeros(1,exp_inform.n_bip_ch);
for i_ch = 1 : exp_inform.n_bip_ch
    id_emg_onset(i_ch) = ...
        predict(exp_inform.model.model_tree_emg_onset,temp_rms(i_ch));
end
cq.emg_onset4mv.add(id_emg_onset);
%=========================================================================%

%=============SAVE FEATURES with insturction(or triggers)=================%
if(GUI.id_start_fe==1)
    % inqueue of feature extracted during 3 s 
    cq.featset.addArray(temp_feat);

    if cq.featset.datasize == cq.featset.length  
        exp_inform.FeatSet{exp_inform.i_trl} = cq.featset.data;

        if isempty(exp_inform.FeatSet{exp_inform.i_trl})
            keyboard;
        end

        % feature buffer init
        cq.featset = circlequeue(exp_inform.n_win,...
            exp_inform.n_bip_ch*3+exp_inform.n_bip_ch*4);

        % for FE GUI
        GUI.id_start_fe = 0;

        % go next facial expression
        exp_inform.i_trl = exp_inform.i_trl +1;
        
    end
end
%=========================================================================%

%+++++++++++++++++++++++++++test mode+++++++++++++++++++++++++++++++++++++%
if GUI.handles.radiobutton_test.Value
%     % classification of each emotion
%     [temp_output,temp_score] = predict(exp_inform.model_from_train{i_cf},...
%         temp_feat(exp_inform.idx_ch_FE2classfy{i_cf}));
%     cq.output_emotion
    
    myStop;
    % classification of each faical unit
    for i_cf = 1 : exp_inform.n_cf
        [temp_output,temp_score] = predict(exp_inform.model_FE{i_cf},...
        temp_feat(exp_inform.idx_ch_FE2classfy{i_cf}));
    
        % add outputs
        cq.output_test{i_cf}.addArray(temp_output);
        cq.output_score{i_cf}.addArray(temp_score);
        
    end
   

    % datasize
    if cq.output_test{1}.datasize == cq.output_test{1}.length
        
        
        % majority voting
        output_test = cell(exp_inform.n_cf,1);
        output_mv = NaN(1,exp_inform.n_cf);
        ouput_score = NaN(1,exp_inform.n_cf);
        for i_cf = 1 : exp_inform.n_cf 
            % get outputs
            output_test{i_cf} = cq.output_test{i_cf}.getLastN(cq.output_test{i_cf}.length);
        
            temp_pd = cq.output_score{i_cf}.getLastN(cq.output_score{i_cf}.length);
            
            temp_output_score_avg = mean(temp_pd,1);
            [ouput_score(i_cf), tmp_idx] = max(temp_output_score_avg);
            output_mv(i_cf) = exp_inform.idx_FE2classfy{i_cf}(tmp_idx);
        end
        
         %-------- emg onset using majority voting
         temp_emg_onset = cq.emg_onset4mv.getLastN(cq.emg_onset4mv.length);
         id_emg_onset_chan = NaN(1,exp_inform.n_bip_ch);
         for i_ch = 1 : exp_inform.n_bip_ch
             [~,tmp_idx] = max(countmember(exp_inform.idx_emg_onest,...
                 temp_emg_onset(:,i_ch)));
             id_emg_onset_chan(i_ch) = exp_inform.idx_emg_onest(tmp_idx);
         end
         id_emg_onset_final = NaN(1,exp_inform.n_cf);
         id_emg_onset_final(1) = ...
             any([id_emg_onset_chan(2),id_emg_onset_chan(3)]);
         id_emg_onset_final(2) = ...
             any([id_emg_onset_chan(1),id_emg_onset_chan(4)]);
        %-------------------
%             disp(id_emg_onset_final);
%             disp(output_mv);
         
            %-----------EYE-BROW EMG: ON LIP-BROW EMG: ON-------------%
            if id_emg_onset_final(1) == 1 && id_emg_onset_final(2) == 1
                if ouput_score(1) < ouput_score(2)

                % get possible eye brow expressions based on lip shapes
                possible_eyebrows = ...
                    natural_eye_brow_exp_selctor(output_mv(2));

                % set eye brow within possible eye brow expression
                output_mv(1) = get_output_within_possible_outcomes(...
                    possible_eyebrows,output_test{1});
                else

                % get possible lip expressions based on eye-brow
                possible_lips = ...
                    natural_lip_exp_selctor(output_mv(1));

                % set lip expression within possible lip expressions
                output_mv(2) = get_output_within_possible_outcomes(...
                    possible_lips,output_test{2});
                end
            %---------------------------------------------------------%

            %-----------EYE-BROW EMG: ON LIP-BROW EMG: OFF------------%
            elseif id_emg_onset_final(1) == 1 && id_emg_onset_final(2) == 0
                if output_mv(1) == 1 || output_mv(1) == 11
                    % get possible lip expressions based on eye-brow
                    possible_lips = ...
                    natural_lip_exp_selctor(output_mv(1));

                    % set lip expression within possible lip expressions
                    output_mv(2) = get_output_within_possible_outcomes(...
                    possible_lips,output_test{2});
                else
                    output_mv(2) = 9;
                end
            %---------------------------------------------------------%

            %-----------EYE-BROW EMG: OFF LIP-BROW EMG: ON------------%
            elseif id_emg_onset_final(1) == 0 && id_emg_onset_final(2) == 1
%                     output_mv(1) = 9;
                % get possible eye brow expressions based on lip shapes
                possible_eyebrows = ...
                    natural_eye_brow_exp_selctor(output_mv(2));

                % set eye brow within possible eye brow expression
                output_mv(1) = get_output_within_possible_outcomes(...
                    possible_eyebrows,output_test{1});
            %---------------------------------------------------------%

            %-----------EYE-BROW EMG: OFF LIP-BROW EMG: OFF-----------%
            elseif id_emg_onset_final(1) == 0 && id_emg_onset(2) == 0
                output_mv(1) = 9;
                output_mv(2) = 9;
            end
            %---------------------------------------------------------%
        
        
        
        % presentation of classfied facial expression
        temp_output_eye = exp_inform.name_gesture_clfr{1}{output_mv(1)};
        temp_output_lip = exp_inform.name_gesture_clfr{2}{output_mv(2)};
        GUI.handles.edit_classification.String = ...
            sprintf('EYE-BROW: %s LIP: %s',...
            temp_output_eye,temp_output_lip);
            
        
        % show avartar
%         myStop;
%         a=1
        plot_avartar(GUI.handles.axes_avartar,temp_output_eye,...
            'neutral',temp_output_lip);
        fprintf(exp_inform.udp,temp_output_eye);
        fprintf(exp_inform.udp,temp_output_lip);
        disp(temp_output_eye);
        disp(temp_output_lip);

        %------do serial communication to control avartar-------------%
        %             fprintf(exp_inform.PC_serial, num2str(fp));
        %-------------------------------------------------------------%
    end

end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

%==================WHEN EXPERIMENT HAS BEEN FINISHED======================%
% you should not confuse the trial has to be more 1,becasue the last trial
% should be proccessed
if exp_inform.i_trl == exp_inform.n_fe+1 % 11번째까지 다마치고 12번쨰로 바뀔 때가 끝임
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
