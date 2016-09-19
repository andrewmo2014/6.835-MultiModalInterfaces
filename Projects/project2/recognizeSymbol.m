% function nearest = recognizeSymbol(testimage, trainimages)
%   Return the nearest neighbor of the feature image 'testimage' in the
%   training set 'trainimages'.

function nearest = recognizeSymbol(testimage, trainimages)
    
    N = size(trainimages, 2);

    function sum = IDM_distance( im1, im2 )
        sum = 0;
        orientations = size(im1,3);
        dim = size(im1,1);
        for o=1:orientations
            for x=1:dim
                for y=1:dim
                    sum = sum + (im1(x,y,o) - im2(x,y,o))^2;
                end
            end
        end
    end

    best_image = trainimages(1);
    best_dist = IDM_distance(testimage, best_image.fimg);
    %best_index = 1;
    
    for n=2:N
        im = trainimages(n);
        dist = IDM_distance(testimage, im.fimg);
        if dist<best_dist
            best_image = im;
            best_dist = dist;
            %best_index = n;
        end
    end
    
    nearest = best_image;
       
end

