function [ statesSteps, statesHr ] = predict( dsoutTrain, dsoutUnknown )
%PREDICT Summary of this function goes here
%   Detailed explanation goes here

    windowWidth = 200;
    
    [ TRANS_STEPS, EMIS_STEPS ] = estimateSteps( dsoutTrain, windowWidth );
    [ TRANS_HR, EMIS_HR ] = estimateHR( dsoutTrain, windowWidth );
    
    seqSteps = calculateSEQ_Steps( dsoutUnknown, windowWidth );
    seqHr = calculateSEQ_Hr( dsoutUnknown, windowWidth );
    
    statesSteps = hmmviterbi( seqSteps, TRANS_STEPS, EMIS_STEPS, 'Statenames',{'awake';'sleeping'} );
    statesHr = hmmviterbi( seqHr, TRANS_HR, EMIS_HR, 'Statenames',{'awake';'sleeping'} );
end
