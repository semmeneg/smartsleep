function [ PAL ] = calcPalForDay( userDetails, metrics )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %daily calories estimation for the given user
    dailyCalories = calculateDailyCalories( userDetails );

    calories = metrics.metrics.calories.values;
    % replace NaN by 0
    calories( find( isnan( calories ) ) ) = 0;
    
    totalCalories = sum( calories );
    
    PAL = totalCalories / dailyCalories;
end

