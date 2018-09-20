% This code is modified by Hoseung Cha (2018.09.10) based on
% Will Dwinnell and Deniz Sevis's LDA matlab code

% Use:
% W = LDA('MDL',mdl) (when you have model)
% W = LDA('X',X,'Y',Y) (first time)
%
% W       = discovered linear coefficients (first column is the constants)
% X   = predictor data (variables in columns, observations in rows)
% Y  = Y variable (class labels)
% Priors  = vector of prior probabilities (optional)
%
% Note: discriminant coefficients are stored in W in the order of unique(Y)
%
% Example:
%
% % Generate example data: 2 groups, of 10 and 15, respectively
% X = [randn(10,2); randn(15,2) + 1.5];  Y = [zeros(10,1); ones(15,1)];
%
% % Calculate linear discriminant coefficients
% W = LDA(X,Y);
%
% % Calulcate linear scores for training data
% L = [ones(25,1) X] * W';
%
% % Calculate class probabilities
% P = exp(L) ./ repmat(sum(exp(L),2),[1 2]);



function mdl = fitLDA(varargin)
% define defaults
mdl = struct(...
    'MDL',[],...
    'X',[],...
    'Y',[],...
    'Priors',[],...
    'GroupMean',[],...
    'PooledCov',[]...
    );

% set argument
mdl = chaSetArgument(mdl,varargin);
if ~isempty(mdl.MDL)
    mdl = mdl.MDL;
end

if isempty(mdl.GroupMean) && isempty(mdl.PooledCov)
% Determine size of X data
[n mdl.nFeat] = size(mdl.X);


% Discover and count unique class labels
mdl.Label = unique(mdl.Y);
mdl.nClass = length(mdl.Label);

% Initialize
nGroup     = NaN(mdl.nClass,1);     % Group counts
if isempty(mdl.GroupMean), mdl.GroupMean  = NaN(mdl.nClass,mdl.nFeat);end     % Group sample means
if isempty(mdl.PooledCov), mdl.PooledCov  = zeros(mdl.nFeat,mdl.nFeat);end  % Pooled covariance


% Loop over classes to perform intermediate calculations
for i = 1:mdl.nClass
    % Establish location and size of each class
    Group      = (mdl.Y == mdl.Label(i));
    nGroup(i)  = sum(double(Group));
    
    % Calculate group mean vectors
    
    mdl.GroupMean(i,:) = mean(mdl.X(Group,:));
    
    % Accumulate pooled covariance information
    mdl.PooledCov = mdl.PooledCov + ((nGroup(i) - 1) / (n - mdl.nClass) ).* cov(mdl.X(Group,:));
end
end

% Assign prior probabilities
if  isempty(mdl.Priors)
    mdl.Priors = nGroup / n;
end

W          = NaN(mdl.nClass,mdl.nFeat+1);   % model coefficients
% Loop over classes to calculate linear discriminant coefficients
for i = 1:mdl.nClass
    % Intermediate calculation for efficiency
    % This replaces:  opt.GroupMean(g,:) * inv(opt.PooledCov)
    if rank(mdl.PooledCov)<mdl.nFeat
        Temp = mdl.GroupMean(i,:)*pinv(mdl.PooledCov);
    else
        Temp = mdl.GroupMean(i,:) / mdl.PooledCov;
    end
    
    % Constant
    W(i,1) = -0.5 * Temp * mdl.GroupMean(i,:)' + log(mdl.Priors(i));
    
    % Linear
    W(i,2:end) = Temp;
end
mdl.W = W;



end


% EOF


