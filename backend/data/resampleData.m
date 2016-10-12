function [ resampledData ] = resampleData( data, originalHz, targetHz )
%RESAMPLEDATA Summary of this function goes here
%   Detailed explanation goes here

    [ dataSamplesCount, dataDim ] = size( data );
    dataIdx = 1 : dataSamplesCount;

    startValue = 1;
    endValue = dataSamplesCount;

    stepSize = originalHz / targetHz;
    interpolationIdx = round( startValue:stepSize:endValue );
    
    resampledData = zeros( length( interpolationIdx ), dataDim );
    
    % NOTE: assuming the timeseries of the data to be continuous: one recording
    % session without holes. QUESTION: would it be a problem if there are
    % holes?
    for i = 1 : dataDim
        resampledData( :, i ) = interp1( dataIdx, data( :, i ), interpolationIdx, 'linear' );
    end
end
