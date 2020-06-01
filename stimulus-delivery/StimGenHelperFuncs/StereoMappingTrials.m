function [trials] = StereoMappingTrials(table)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%CREATE A PARAMETERS AND CONSTANTS STRUCTURE %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:size(table,1)
    %Find the strings from the 1st column of the table breaking at the '('
    tableStrings{i} = strtok(table{i,1},'(');
    %remove trailing spaces
    tableStrings{i} = strtrim(tableStrings{i});
    %construct a fieldname by replacing the white space with '_'
    fieldname{i} = strrep(tableStrings{i},' ','_');
    

    % We will create 2 temporary structures. One will hold parameters to be
    % varied and the other will hold constants (we initialized them above
    % because we want to check whether they are empty later)
    
    % RULES FOR VALID PARAMETERS
    % If all columns after the first are numbers and if the numel of a row 
    % in the table >2 and the first and last values are not equal then we 
    % have a parameter to add to the params struct.
    % Note we meed to exclude the timing becasue it does not follow
    % start:step:end AND contrast becasue it will be varied logarithmically
    % not linearly and also does not follow start:step:end but rather
    % start,end,num_steps
    
    % Check if row contains strings, if so store to constants structure
    if ischar([table{i,2:end}])
        constants.(fieldname{i}) = {table{i,2:end}};
        
    % Check if row is the Height or Width row if so add to constants structure    
    elseif strcmp(fieldname{i},'Height')
        constants.(fieldname{i}) = horzcat(table{i,2:4});
        
    elseif strcmp(fieldname{i}, 'Width')
        constants.(fieldname{i}) = horzcat(table{i,2:4});
        
    % Check number of elements in the row if less than 2 add to constants
    elseif numel(cell2mat(table(i,2:end))) <= 2 % 2 element rows
        constants.(fieldname{i}) = horzcat(table{i,2:4});
      % Check if row is Contrast row and the check whether exponent 1 equals
    % exponent 2
    elseif strcmp(fieldname{i},'Contrast') && table{i,3} == table{i,4}
        % The constant contrast will be the highest contrast or 1
        constants.(fieldname{i}) = min(table{i,2}^table{i,4},100)/100;
        
    % Else if row is contrast and exp1 ~= exp 2
    elseif strcmp(fieldname{i},'Contrast') && table{i,3} ~= table{i,4}
        % we will loop over the exponent range and construct the contrast
        for exponent = table{i,3}:table{i,4}
            contrast(exponent) = table{i,2}^exponent/100;
        end
        % we limit the contrast to values <= 1 and use one only once
        contrast = unique(min(contrast,1));
        params.Contrast = contrast;
        
    % Check whether start and end vals are the same. If so add to constants
    elseif numel(cell2mat(table(i,2:end))) >2 && table{i,2}==table{i,4}
        constants.(fieldname{i}) = table{i,2};
    % Else if start and end not same add to the params structure
    elseif numel(cell2mat(table(i,2:end))) >2 && table{i,2}~=table{i,4}
        params.(fieldname{i}) = table{i,2}:table{i,3}:table{i,4};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREATE TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_trials = 30;
trials(N_trials * constants.Repeats) = struct();

%permutate possible combinations
stim_velocities = [];

for r = 1:constants.Repeats
    p = randperm(N_trials);
    stim_velocities = [stim_velocities p];
end

%%%%% debug
%stim_locations = 1:N_trials*constants.Repeats;

%generate trial struct
for i = 1:N_trials*constants.Repeats
    trials(i).stimType = "Stereo Bar noRotation";
    for j = 1:numel(fieldname)
        trials(i).(fieldname{j}) = constants.(fieldname{j});
    end
    trials(i).stim_velocities = stim_velocities(i);
end
end