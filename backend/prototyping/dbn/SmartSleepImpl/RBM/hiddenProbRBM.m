function [ prob ] = hiddenProbRBM( RBM, visibleProb )
%ACTIVATERBM Summary of this function goes here
%   Detailed explanation goes here

    prob = 1./(1 + exp( -visibleProb * RBM.W - RBM.b ) );

end

