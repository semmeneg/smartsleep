% Normalize values to given range.
%
function [ normalizedData ] = normalizeToRangeWithMinMax(values, a, b, minValue, maxValue)
    normalizedData = a+((values-minValue)*(b-a))/(maxValue-minValue);
end

