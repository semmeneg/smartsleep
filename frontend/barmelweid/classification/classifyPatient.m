function [ bestReducedLabels, reducedLabelsErrors ] = classifyPatient( patientUnclassifiedArffFile, ...
		trainedModelFile, wekaPath, windowLength )

	[ o, classificationData ] = classifyWithWEKAModel( wekaPath, ...
        trainedModelFile, patientUnclassifiedArffFile, true );

	instanceLabels = classificationData( :, 1 );
	instanceCount = length( instanceLabels );

	reducedLabelsCount = floor( instanceCount / windowLength );
	reducedLabels = zeros( reducedLabelsCount, windowLength );
	reducedLabelsTime = zeros( reducedLabelsCount, windowLength );
	reducedLabelsErrors = zeros( windowLength, 1 );

	for i = 1 : windowLength
		nextIdx = 1;
		
		for windowStartIdx = i : windowLength : instanceCount
			windowEndIndex = windowStartIdx + windowLength - 1;
			if ( windowEndIndex > instanceCount )
				break;
			end

			labelsInWindow = instanceLabels( windowStartIdx : windowEndIndex );

			% PROBLEM: what if bins are equal? which one is selected? 
			% using the error function below we cannot tackle this problem.
			% unfortunately it could be responsible for oscilations (+/-1
			% class)
			[ labelCount, labelBins ] = hist( labelsInWindow, unique( labelsInWindow ) );

			[ val, idx ] = max( labelCount );

			reducedLabelsErrors( i ) = reducedLabelsErrors( i ) + ( windowLength - val );
			reducedLabels( nextIdx, i ) = labelBins( idx );
			
			nextIdx = nextIdx + 1;
		end
	end

	[ minErrors, minErrorIdx ] = min( reducedLabelsErrors );
	bestReducedLabels = reducedLabels( :, minErrorIdx );