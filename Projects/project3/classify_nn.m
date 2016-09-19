% CLASSIFY_NN: nearest neighbor classifier. Returns the label index of the
% nearest neighbor to the test gesture in the training set.

function [label] = classify_nn(test, train)

    D = size(test,1);
    N = size(test,2);
    
    numGestures = length(train); % number of gesture types
    new_train = normalize_frames(train, N);
    
    minDist = inf;
    bestGesture = -1;
    for n=1:numGestures
        M = length(new_train{n});
        for m=1:M
            distance = norm(test-new_train{n}{m});
            if distance <= minDist
                minDist = distance;
                bestGesture = n;
            end
        end
    end
        
    label = bestGesture;
end