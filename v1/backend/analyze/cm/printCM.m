function [ ] = printCM( stream, classes, cm )
%CALCCONFUSIONMAT Summary of this function goes here
%   Detailed explanation goes here

    if ( size( cm ) ~= size( cm ) )
        error( 'Confusion-matrix must be square - exit' );
    end
   
    classCount = length( classes );
    
    if ( classCount ~= length( cm ) )
        error( 'Confusion-matrix must have same number of rows as classes - exit' );
    end

    totalErrors = 0;
    
    for i = 1 : classCount
        totalEntries = sum( cm( i, : ) );
        
        % if no labels for this class present, then ignore in printout
        if ( 0 == totalEntries )
            continue;
        end
        
        correctEntries = cm( i, i );
        errorEntries = totalEntries - correctEntries;
        correctPercent = correctEntries / totalEntries;
        
        totalErrors = totalErrors + errorEntries;
        
        fprintf( stream, '%-20s: %-3d (%.2f) correct, %-3d wrong', classes{ i }, ...
            correctEntries, correctPercent, errorEntries );
        
        if ( 0 ~= errorEntries )
            fprintf( stream, ' -> ' );
            
            previousEntry = false;
            
            for j = 1 : classCount
                if ( j == i )
                    continue;
                end

                if ( 0 ~= cm( i, j ) )
                    if ( previousEntry )
                        fprintf( stream, ', ' );
                    end
                    
                    fprintf( stream, '%d %s', cm( i, j ), classes{ j } );
                    previousEntry = true;
                end
            end
        end
        
        fprintf( stream, '\n' );
    end

    totalCorrect = trace( cm );
    totalSamples = totalCorrect + totalErrors;
    
    fprintf( stream, '\n' );
    fprintf( stream, 'Total Number of Instances         %-3d\n', totalSamples );
    fprintf( stream, 'Correctly Classified Instances    %-3d \t %0.2f %%\n', totalCorrect, 100 * ( totalCorrect / totalSamples ) );
    fprintf( stream, 'Incorrectly Classified Instances  %-3d \t %0.2f %%\n', totalErrors, 100 * ( totalErrors / totalSamples ) );
end