function [accuracies] = BEST_test_nn(gestures, ratioSplit)

    accuracies = [];
    for i=10:2:30
        accuracy = test_nn(normalize_frames(gestures,i), ratioSplit);
        accuracies(end+1) = accuracy;
        display(i);
        display(accuracy);
    end
end