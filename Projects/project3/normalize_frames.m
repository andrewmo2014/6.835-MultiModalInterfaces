% NORMALIZE_FRAMES: takes a gesture dataset and normalizes the length of
% each gesture{i}{j} to nsamples.

function fixed_data = normalize_frames(data, nsamples)

    numGestures = size(data);
    numExamples = size(data{1});
    
    for i=1:numGestures(2)        
        fixed_data{i} = cell(1,numExamples(2));

        for j=1:numExamples(2)
            
            M = data{i}{j};
            L = size(M);
            numPoses = L(1);
            numFrames = L(2);
                        
            %Determine ratio
            ratio = mod(nsamples, numFrames) / numFrames;
            addCols = false;
            if numFrames <= nsamples
                addCols = true;
            end
                        
            for index=1:numFrames
                
                factor = mod(index*nsamples, numFrames) / numFrames;
                threshold = (factor < ratio) ;
                
                if ~addCols
                    if (threshold)
                        fixed_data{i}{j}(:,end+1) = data{i}{j}(:,index);
                    end
                else
                    fixed_data{i}{j}(:,end+1) = data{i}{j}(:,index);
                    if (threshold)
                        fixed_data{i}{j}(:,end+1) = data{i}{j}(:,index);
                    end
                end
            end
        end
    end
end
