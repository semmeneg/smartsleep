function [ activityIdx ] = getActivity( t, activities )
%GETACTIVITYWITHIN Summary of this function goes here
%   Detailed explanation goes here

    % Returns the index of the activity the given timestamp t falls in
    % between start and end. If no such activity is found then -1 is
    % returned

    activityIdx = -1;
    
    for i = 1 : length( activities )
        if ( activities{ i }.start <= t && activities{ i }.end >= t )
            activityIdx = i;
            return;
        end
    end
end
