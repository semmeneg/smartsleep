function [ ms ] = durationToMs( hours, minutes, seconds, secondsFraction )
%DURATIONTOMS Summary of this function goes here
%   Detailed explanation goes here

    ms = hours * 3600 * 1000;
    ms = ms + minutes * 60 * 1000;
    ms = ms + seconds * 1000;
    ms = ms + secondsFraction * 10;
end

