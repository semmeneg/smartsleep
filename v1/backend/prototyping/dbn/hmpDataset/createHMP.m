function [ hmp ] = createHMP( data, labels )
%CREATEWISDM Summary of this function goes here
%   Detailed explanation goes here

    hmp = [];
    hmp.params.sampleRate = 32;                  % NOTE CHEST-dataset is sampled at 32Hz
    hmp.params.windowSizeTime = 6700;            % 6.7 seconds of window-size
    hmp.params.windowOverlapRatio = 0.5;
    hmp.params.mixChannels = false;
    hmp.raw.data = data;
    hmp.raw.labels = labels;
    hmp.classes = { 'Brush_teeth', 'Climb_stairs', 'Comb_hair', 'Descend_stairs', ...
        'Drink_glass', 'Eat_meat', 'Eat_soup', 'Getup_bed', 'Liedown_bed', ...
        'Pour_water', 'Sitdown_chair', 'Standup_chair', 'Use_telephone', 'Walk' };
end
