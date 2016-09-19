% function [accuracy errors] = evalAll(symbols)
%   Evaluate the recognizer on a set of 'symbols', using the first 60% as 
%   training and the remaining as test. Returns the accuracy rate and a 
%   list of errors (as indices).

% returns a list with the optimal [h, SLOPE_WINDOW, SIGMA]

function params = evalAllBestParams(symbols)
    H_LIST = [12 16 20 24 28 32];
    TANWINDOW_LIST = [2 5 10 15 18];
    SIGMA_LIST = [0.5 0.75 1.0 1.25 1.5 1.75 2];
    
    best_accuracy = -1;
    best_params = [];
    for h_i=1:length(H_LIST)
        display(h_i);
        for t_i=1:length(TANWINDOW_LIST)
            for s_i=1:length(SIGMA_LIST)
                [accuracy, errors] = ...
                    evalAllBest(symbols,H_LIST(h_i),TANWINDOW_LIST(t_i), SIGMA_LIST(s_i));
                if best_accuracy < 0
                    best_accuracy = accuracy;
                    best_params = [H_LIST(h_i), TANWINDOW_LIST(t_i), SIGMA_LIST(s_i)];
                elseif accuracy > best_accuracy
                    best_accuracy = accuracy;
                    best_params = [H_LIST(h_i), TANWINDOW_LIST(t_i), SIGMA_LIST(s_i)];
                end
            end
        end
    end
    
    display(best_accuracy);
    params = best_params;

        
    %Eval with best params
    %Copied but given params
    function [accuracy, errors] = evalAllBest(symbols, h, t, s)
        cutoff = round(length(symbols)*0.6);
        train = symbols(1:cutoff);
        test = symbols(cutoff+1:length(symbols));

        for i = 1:length(train)
            trainimages(i) = struct('fimg', createFeatureImageBest(train(i), h, t, s), ...
                                    'label', train(i).label);
        end
        correct = 0;
        close all
        figure;
        errors = [];
        for i = 1:length(test)
            testimage = createFeatureImageBest(test(i), h, t, s);
            prediction = recognizeSymbol(testimage, trainimages);
            if (prediction.label == test(i).label)
                correct = correct + 1;
            else
                errors = [errors i+length(train)];
                if (length(errors) <= 16)
                    subplot(4,4,length(errors));
                    displaySymbol(test(i));
                    title(sprintf('%d as %d (%d)', test(i).label, ...
                        prediction.label, i+length(train)));
                end
            end
        end    
        accuracy = correct/length(test);
    end

    %Copied but given params
    function fimg = createFeatureImageBest(symbol, h, t, s)
        fimg = zeros(h, h, 4);

        % Define Parameters
        numberPoints = size(symbol.x);
        N = numberPoints(1);
        STD_FACTOR = h/5;
        SHIFT_FACTOR = h/2;
        REF_ANGLES = [0; pi/4; pi/2; 3*pi/4];
        K = size(REF_ANGLES);

        start = symbol.y;
        symbol.y = symbol.x;
        symbol.x = start;

        %%Part 1: Calculate Tangent Slopes
        function tangentSlopes = determineTangentSlopes(x,y,w)
            tangentSlopes = zeros(size(x));
            L = size(x);
            for i=1:L
                high =  min(i+w, N);
                low =   max(i-w, 1);
                tangentSlopes(i) = (y(high) - y(low)) / (x(high) - x(low));
            end
        end

        %%Part 2: Convert Slopes to angles
        x = symbol.x;
        y = symbol.y;
        w = t;
        angles = atan(determineTangentSlopes(x,y,w));

        %%Part 3: Standardize Symbol
        % Mean is (0,0)
        x = x - mean(x);
        y = y - mean(y);

        % Scale deviation by H/5
        x = (x / std(x)) * STD_FACTOR;
        y = (y / std(y)) * STD_FACTOR;

        % Shift to (H/2,H/2)
        x = x + SHIFT_FACTOR;
        y = y + SHIFT_FACTOR;

        %%Part 4: Render points on feature images
        for k=1:K
            for n=1:N-1
                if symbol.s(n) ~= symbol.s(n+1)
                    continue
                end

                % Calculate angles
                theta = mod(angles(n), pi);
                ref_theta = mod(REF_ANGLES(k), pi);
                orientation = abs(theta - ref_theta);

                % Determine intensity
                % Difference vary linearly (from equal to differing by pi/4)
                intensity = max(1.0 - orientation/(pi/4), 0.0);
                if orientation == pi    % Multiple of pi
                    intensity = 1.0;
                end

                [x_coords,y_coords] = makeLine( x(n), y(n), x(n+1), y(n+1) ); 
                numLines = size(x_coords);
                for l=1:numLines
                    % Clipping X
                    x_val = ceil( x_coords(l) );
                    if x_val < 1.0;     x_val = 1.0;    end;
                    if x_val > h;       x_val = h;      end;
                    % Clipping Y
                    y_val = ceil( y_coords(l) );
                    if y_val < 1.0;     y_val = 1.0;    end;
                    if y_val > h;       y_val = h;      end;
                    % fimg                
                    fimg(x_val, y_val, k) = ...
                        min(intensity + fimg(x_val, y_val, k), 1.0);
                end
            end
        end

        %%Part 5: Smoothing
        smooth = fspecial('gaussian', [3 3], s);
        fimg = imfilter(fimg, smooth);
    %     
    %     clf;
    %     displayImage(fimg, symbol);

        fimg = downsample(fimg);
    end

end