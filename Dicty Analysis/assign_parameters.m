%%%%%%%%%% ASSIGN PARAMETERS %%%%%%%%%%

% Any variable stored in the structure parameters is made a working
% variable outside of the parameters structure.

parameters.test=1;
names = fieldnames(parameters);
for k=1:length(names)
    
    if isfield(parameters, names{k})
        
        if ~strcmp(names{k}, 'test')
            toName=sprintf('parameters.%s', names{k});
            toEval = sprintf('%s = %s',names{k},toName);
            eval(toEval);
        end
        
    end
    
end
