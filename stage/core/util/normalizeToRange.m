% Normalize values to given range.
%
function [ normalizedData ] = normalizeToRange(values, a, b)
    minValue=min(values);
    maxValue=max(values);
    normalizedData = a+((values-minValue)*(b-a))/(maxValue-minValue);
end

