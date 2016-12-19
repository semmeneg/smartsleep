function [ ] = printCMStandard( stream, classes, cm, isRelative )
%CALCCONFUSIONMAT Summary of this function goes here
%   Detailed explanation goes here

    if ( size( cm ) ~= size( cm ) )
        error( 'Confusion-matrix must be square - exit' );
    end
   
    classCount = length( classes );
    
    if ( classCount ~= length( cm ) )
        error( 'Confusion-matrix must have same number of rows as classes - exit' );
    end

    
    for i = 1 : classCount 
        for j = 1 : classCount
            if ( isRelative )
                fprintf( stream, '%6.2f%%\t ', 100 * cm( i, j ) );
            else
                fprintf( stream, '%6d\t ', cm( i, j ) );
            end            
        end
        
        fprintf( stream, '| %s\n', classes{ i } );
    end
end