function [ bestAccuracy, bestX, bestY, bestW ] = BEST_hmm( gestures, ratioSplit )

    warning('off', 'all');
    startX = 7; %num hidden states
    startY = 7; %num mix gaussians
    startW = 0; %num window size
    endX = 7;   
    endY = 7;
    endW=15;

    bestAccuracy = -inf;
    bestX = -1;
    bestY = -1;
    bestW = -1;
    for w=startW:endW
        gestureW = add_velocities(gestures, w);
        for x=startX:endX
            for y=startY:endY
                try
                    [model, a] = experiment_hmm(gestureW, ratioSplit, x, y);
                catch
                    break; %Matrix error
                end
                if (a > bestAccuracy)
                    bestAccuracy = a;
                    bestX = x;
                    bestY = y;
                    bestW = w;
                end
            end
        end
    end
    
    warning('on', 'all');
end

