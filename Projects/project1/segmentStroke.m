function [ segpoints, segtypes ] = segmentStroke( stroke )
    % Switch off some specific warnings from regress
    warning('off', 'stats:regress:RankDefDesignMat');
    warning('off', 'MATLAB:rankDeficientMatrix');

    %Paremeter Definitions
    %Given
    penSpeedSmoothWinSize = 5;          % 5 // total (2 points on each side)
    tanWinSize = 10;                    % 11 // size of window for computing tangent
    speedThresh1Perc = .25;             % speed threshold 1 percentage of average spped
    curveThreshPerc = .75;              % curvature threshold in degress per pixel
    speedThresh2Perc = .8;              % speed threshold 2 percentage of average speed
    minCornDist = 240;                  % minimum allowed distance between two corners
    minArcAngle = 36;                   % minimum arc angle
    
    minStartDist = 450;                 % minimum start distance
    
    %Calculate total number of points
    numberPointsArray = size(stroke.x);
    numberPoints = numberPointsArray(1);
    
    %%Part 1
    %Function to determine distance between consecutive pairs
    function length = euclidDist(x1, y1, x2, y2)
        length = sqrt( (x2-x1)^2 + (y2-y1)^2 );
    end

    %Calculate arcLengths
    lengthArcs = zeros(1, numberPoints);
    lengthArcs(1) = 0;
    for i=2:size(stroke.x)
        x1 = stroke.x(i-1);
        y1 = stroke.y(i-1);
        x2 = stroke.x(i);
        y2 = stroke.y(i);
        lengthArcs(i) = lengthArcs(i-1) + euclidDist(x1,y1,x2,y2);
    end
    
    %%Part 2
    %Function to determine pen speed
    function speed = speedOfPenIndex(index)
        halfWin = floor(penSpeedSmoothWinSize / 2);
        if (index < 1 + halfWin);               speed = speedOfPenIndex(1 + halfWin); 
            return; 
        end
        if (index > numberPoints - halfWin);    speed = speedOfPenIndex(numberPoints - halfWin); 
            return; 
        end
        
        %Use equation in report
        d_ip1 = lengthArcs(index + halfWin);
        d_im1 = lengthArcs(index - halfWin);
        t_ip1 = stroke.t(index + halfWin);
        t_im1 = stroke.t(index - halfWin);
        speed = (d_ip1 - d_im1) / (t_ip1 - t_im1);
    end

    %Calculate pen speeds
    penSpeeds = zeros(1, numberPoints);
    for i=1:numberPoints
        penSpeeds(i) = speedOfPenIndex(i);
    end

    %%Part 3
    %Function to determine tangents
    function tangent = slopeOfPenIndex(index)
        halfWin = floor(tanWinSize / 2);
        maxi = min(index + halfWin, numberPoints);
        mini = max(index - halfWin, 1);
        count = maxi - mini + 1;
        y = stroke.y(mini:maxi);
        X = [ones(count,1), (1:count)'];
        tangent = regress(y, X);
    end

    %Calculate tangents
    tangents = zeros(1, numberPoints);
    for i=1:numberPoints
        tangent = slopeOfPenIndex(i);
        tangents(i) = tangent(2);
    end

    %%Part 4
    %Calculate "corrected" angles from arc tangents
    angles = correctAngleCurve(atan(tangents));
%    display(angles)
    
    %Plot Stroke 3
%     ltans = size(tangents);
%     L = ltans(2);
%     figure
%     plot(linspace(0,L-1,L)', tangents);         %ORIGINAL
%     figure
%     plot(linspace(0,L-1,L)', atan(tangents));   %SLOPES
    
    %Function to determine curvature
    function curve = curvatureOfPenIndex(index)
        halfWin = floor(tanWinSize / 2);
        maxi = min(index + halfWin, numberPoints);
        mini = max(index - halfWin, 1);
        count = maxi - mini + 1;
        y = angles(mini:maxi)';
        X = [ones(count,1), lengthArcs(mini:maxi)'];
        curve = regress(y, X);
    end

    %Calculate curvature
    curvatures = zeros(1, numberPoints);
    for i=1:numberPoints
        curve = curvatureOfPenIndex(i);
        curvatures(i) = curve(2);
    end
    
    %%Part 5
    %Identify corners - Point Criteria
    totalLength = lengthArcs(numberPoints);
    totalTime = ( stroke.t(numberPoints) - stroke.t(1));
    avgSpeed = totalLength / totalTime;
    speedThresh1 = speedThresh1Perc * avgSpeed;
    speedThresh2 = speedThresh2Perc * avgSpeed;
    
    %Negate to use findpeaks function properly
    negatePenSpeeds = -1*penSpeeds;
    [speedPeaks, speedPeakLocs] = findpeaks(negatePenSpeeds);
    speedPeaks = -1*speedPeaks;
    
    speedMatches = [];
    spSize = size(speedPeaks);
    for i=1:spSize(2)
        if speedPeaks(i) < speedThresh1;    speedMatches = [speedMatches, speedPeakLocs(i)];
        end
    end
    
    %Identify corners - Curve Criteria
    [curvePeaks, curvePeakLocs] = findpeaks(curvatures);
    curveMatches = [];
    cpSize = size(curvePeaks);
    for c=1:cpSize(2)
        if curvePeaks(c) > curveThreshPerc
            if penSpeeds(curvePeakLocs(c)) < speedThresh2; curveMatches = [curveMatches, curvePeakLocs(c)];
            end
        end
    end
    
    %%Part 6
    %Nearly Coincident Points Merged
    updatedSpeedMatches = [];
    cmSize = size(curveMatches);
    for ci=1:cmSize(2)
        updatedSpeedMatches = speedMatches;
        smSize = size(speedMatches);
        for si=1:smSize(2)
            x1 = stroke.x(curveMatches(ci));    %CX
            y1 = stroke.y(curveMatches(ci));    %CY
            x2 = stroke.x(speedMatches(si));    %SX
            y2 = stroke.y(speedMatches(si));    %SY
            if euclidDist(x1, y1, x2, y2) < minCornDist                
                updatedSpeedMatches = updatedSpeedMatches(updatedSpeedMatches ~= speedMatches(si));
            end
        end
        speedMatches = updatedSpeedMatches;
    end
    
    finalMatches = [curveMatches, speedMatches];
    fmSize = size(finalMatches);
    newFinalMatches = finalMatches;
    for ci=1:fmSize(2)
        for sj=1:fmSize(2)
            if ci == sj;  break;
            end
            x1 = stroke.x(finalMatches(ci));    %CX
            y1 = stroke.y(finalMatches(ci));    %CY
            x2 = stroke.x(finalMatches(sj));    %SX
            y2 = stroke.y(finalMatches(sj));    %SY
            if euclidDist(x1, y1, x2, y2) < minCornDist
                newFinalMatches = newFinalMatches(newFinalMatches ~= finalMatches(sj));
            end
        end
        
        x1 = stroke.x(finalMatches(ci));    %CX
        y1 = stroke.y(finalMatches(ci));    %CY
        x2 = stroke.x(1);                   %Start X
        y2 = stroke.y(1);                   %Start Y
        if euclidDist(x1, y1, x2, y2) < minStartDist
            newFinalMatches = newFinalMatches(newFinalMatches ~= finalMatches(ci));
        end
        
        x2 = stroke.x(numberPoints);        %End X
        y2 = stroke.y(numberPoints);        %End Y
        if euclidDist(x1, y1, x2, y2) < minStartDist
            newFinalMatches = newFinalMatches(newFinalMatches ~= finalMatches(ci));
        end
    end
    finalMatches = newFinalMatches;
    
    %%Part 7
    %Segmentation Identification
    segpoints = sort(finalMatches');
    spSize = size(segpoints);
    
    segtypes = zeros(spSize(1) + 1, 1);

    newSegPoints = [1, segpoints', numberPoints]';
    for i=1:spSize + 1
        y = stroke.y(newSegPoints(i):newSegPoints(i+1));
        count = newSegPoints(i+1) - newSegPoints(i) + 1;
        X = [ones(count, 1), stroke.x(newSegPoints(i):newSegPoints(i+1))];
        
        [b, bint, r, rint, stats] = regress(y,X);
        if stats(1) < 0.05
            segtypes(i) = 1;
        end
    end
    

end

