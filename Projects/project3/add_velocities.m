% ADD_VELOCITIES: takes a gesture dataset and adds 33 velocity/derivative
% feature based on each of the existing position features. The resulting 
% feature matrices should have 66 rows. Does this for each gesture{i}{j}.
% Input w is the temporal window from which to calculate the velocity.

function fixed_data = add_velocities(data,w)
    numGestures = length(data);
    
    for i=1:numGestures
        M = length(data{i});
        fixed_data{i} = cell(1,M);
        
        for m=1:M
            positions = data{i}{m};
            velocities = zeros(size(positions));

            D = size(positions,1);  %33
            N = size(positions,2);
            
            for t=1:N
                velocities(:,t) = positions(:,t) - positions(:,max(t-w,1));
            end
            fixed_data{i}{m} = [positions; velocities];
        end
    end    
end