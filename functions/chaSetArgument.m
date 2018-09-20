function opt = chaSetArgument(opt,varInput)
% check number of input arguments
numvarargs = length(varInput);
% if numvarargs > 8
%     error('requires at most 3 optional inputs');
% end

% read the acceptable names
optionNames = fieldnames(opt);

% check arguments name/value pairs properly
if round(numvarargs/2)~=numvarargs/2
    error('EXAMPLE needs propertyName/propertyValue pairs')
end

% overwriting
for pair = reshape(varInput,2,[]) %# pair is {propName;propValue}
    %    inpName = lower(pair{1}); %# make case insensitive
    inpName = pair{1};
    if any(strcmp(inpName,optionNames))
        opt.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

end