function [ dailyCalories ] = calculateDailyCalories( userDetails )
%CALCULATEDAILYCALORIES Summary of this function goes here
%   Detailed explanation goes here

    % weight is given in pound, transform to KG
    weightInKG = userDetails.anatomy.weight * 0.4535;
    % height is given in inches, transform to CM
    heightInCM = userDetails.anatomy.height * 2.54;
    
    dob = datevec( unixTimeToMatlabTime( userDetails.anatomy.dob ) );
    today = datevec( datetime );
    ageInYears = today( 1 ) - dob( 1 );
    
    % using Harris-Benedict-Formula for estimation of daily calories use
    if 'M' == userDetails.anatomy.gender
        dailyCalories = 66.5 + ( 13.75 * weightInKG ) + ( 5.003 * heightInCM ) - ( 6.775 * ageInYears );
    else
        dailyCalories = 655.1 + ( 9.563 * weightInKG ) + ( 1.850 * heightInCM ) - ( 4.676 * ageInYears );
    end
end

