% Normalize values to given range.
%
function [ normalizedData ] = normalizeToRange(values, allValues, a, b)
    minValue=min(allValues);
    maxValue=max(allValues);
    normalizedData = a+((values-minValue)*(b-a))/(maxValue-minValue);
end

