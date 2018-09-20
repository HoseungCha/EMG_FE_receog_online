% % Calulcate linear scores for training data
% L = [ones(25,1) X] * W';
%
% % Calculate class probabilities
% P = exp(L) ./ repmat(sum(exp(L),2),[1 2]);
% modified by Hoseung Cha
function Ypd = predLDA(mdl,X)
    lenX = size(X,1);
%     nClass = size(W,1);
    L = [ones(lenX,1) X] * mdl.W';
%     P = exp(L) ./ repmat(sum(exp(L),2),[1 nClass]);
    [~,Ypd] = max(L,[],2);
    try
    Ypd = mdl.Label(Ypd);
    catch ex
        keyboard;
    end
end