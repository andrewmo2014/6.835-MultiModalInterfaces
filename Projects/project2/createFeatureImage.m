% function fimg = createFeatureImage(symbol)
%   Create a set of feature images for the input 'symbol' and downsample 
%   the images by a factor of two.

function fimg = createFeatureImage(symbol)
    h = 20; %24/20
    fimg = zeros(h, h, 4);
    
    % Define Parameters
    SLOPE_WINDOW = 2;   %10/2
    numberPoints = size(symbol.x);
    N = numberPoints(1);
    STD_FACTOR = h/5;
    SHIFT_FACTOR = h/2;
    REF_ANGLES = [0; pi/4; pi/2; 3*pi/4];
    K = size(REF_ANGLES);
    SIGMA = 1.5;    %1.0/1.5
    
    % Baseline
    PIXEL_ONLY = false;
    SMOOTHING_ON = true;
    
    %inverse symbol xy
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
    w = SLOPE_WINDOW;
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
            
            if(PIXEL_ONLY)
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
    if (SMOOTHING_ON)
        smooth = fspecial('gaussian', [3 3], SIGMA);
        fimg = imfilter(fimg, smooth);

        %clf;
        %displayImage(fimg, symbol);
    end

    fimg = downsample(fimg);
end