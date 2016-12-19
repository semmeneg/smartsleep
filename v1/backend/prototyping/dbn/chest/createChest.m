function [ chest ] = createChest( data, labels )
%CREATEWISDM Summary of this function goes here
%   Detailed explanation goes here

    chest = [];
    chest.params.uniformClassDistribution = false;
    chest.params.sampleRate = 52;                  % NOTE CHEST-dataset is sampled at 52Hz
    chest.params.windowSizeTime = 6700;            % 6.7 seconds of window-size
    chest.params.windowOverlapRatio = 0.5;
    chest.params.mixChannels = false;

    chest.raw.data = data;
    chest.raw.labels = labels;
    chest.classes = { 'WorkingComputer', 'Standingup/Walking/Upstairs', 'Standing', 'Walking', 'GoingUp/Downstairs', 'Walking&Talking', 'Talking&Standing' };
end
