%--------------------------------------------------------------------------
% train LDA when train is finisehd
%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------

%-----------임시코드-----------%
% LOAD DB 
load(fullfile(cd,'DB','180806_1809_train_mode_online_biosemi_'));
%------------------------------%    
%--------------------------experiment infromation-------------------------%
% feature indexing when using DB of ch4 ver
clear F_list;
F_list.RMS = 1:4;
F_list.WL = 5:8;
F_list.SampEN = 9:12;
F_list.CC = 13:28;
K = 28;

% feat names and indices
name_feat = fieldnames(F_list);
F_list = struct2cell(F_list);
F = length(name_feat);
N1 = 30;
M = exp_inform.n_fe;
T = 1; % transformation feature index
%-------------------------------------------------------------------------%

%----------------------------------load DB--------------------------------%
% load new feature set whose order of facial expression was corrected
feat = cell(exp_inform.n_fe,1);
for i_fe = 1 : exp_inform.n_fe
    feat{exp_inform.order_fe(i_fe)} = exp_inform.FeatSet{i_fe};
end
% change the format of this features as [n_seg, n_feat, n_FE]
feat = cat(3,feat{:});
%-------------------------------------------------------------------------%

%--------------------train-less minimization algorithm--------------------%
% load feature set from DB
tmp = load(fullfile(cd,'DB','feat_seg_pair_1'));
tmp_name = fieldnames(tmp);
feat_DB = getfield(tmp,tmp_name{1}); %#ok<GFLD>
feat_DB = feat_DB(1:exp_inform.n_win,:,:,:,:); % check segments

if T~=0 % use DB
timerVal = tic;
feat_t = get_DB_prime(feat,feat_DB,F_list,T,N1,M,F,K,'Seg_FE');

% arrange feat transformed and target
% concatinating features with types
% display of training time
elapsedTime = toc(timerVal);

fprintf('Elapsed Time is %0.2f s\n', elapsedTime)
else
feat_t = [];
end
%-------------------------------------------------------------------------%

% target for feature  
ytr = repmat(1:M,N1,1); ytr = ytr(:);

% chane dimension for training
feat = concat_leaving_dim(feat,2);
feat_t = concat_leaving_dim(feat_t,2);

% get input and targets for train DB
input = cat(1,feat,feat_t);
target = repmat(ytr,[T+1,1]);                

%============================EACH EMOTION TRAIN===========================%
exp_inform.model.FE_emotion = fitcdiscr(input,target);
%=========================================================================%

% prepare raw_data
exp_inform.raw_data = exp_inform.raw_data(1:exp_inform.raw_pos,:);

%-----------------------------save model and DB---------------------------%
% save reference features and transforemd features from DB
exp_inform.feat_trans = feat_t;
exp_inform.feat_ref = feat;

if isempty(File)
    File.name = '';
end
uisave({'File','exp_inform'},fullfile(cd,'DB',...
    [datestr(now,'yymmdd_HHMM_'),exp_inform.exp_mode,'_',File.name,'.mat']))
%-------------------------------------------------------------------------%






