% Reads and parses Weka result file.
%
classdef WekaResultReader
    
    properties
        fileName = [];
    end
    
    methods
        function obj = WekaResultReader(fileName)
            obj.fileName = fileName;
        end
        
        function [ result ] = run(obj)
            %PARSEWEKARESULT Summary of this function goes here
            %   Detailed explanation goes here
            
            result = [];
            result.totalInstances = 0;
            result.corrAbs = 0;
            result.corrRel = 0;
            result.incorrAbs = 0;
            result.incorrRel = 0;
            result.kappa = 0;
            result.meanAbsErr = 0;
            result.rmsErr = 0;
            result.relAbsErr = 0;
            result.rootRelSquaredErr = 0;
            result.cmAbs = [];
            result.cmRel = [];
            result.classes = [];
            
            SIGNAL_LINE = '=== Stratified cross-validation ===';
            SIGNAL_LINE_ALTERNATIVE = '=== Error on test data ===';
            
            PARSESTATE_SEARCHSIGNALLINE = 1;
            PARSESTATE_SEARCHSIGNALLINE_ALTERNATIVE = 10;
            PARSESTATE_PARSESTATISTICS = 2;
            PARSESTATE_PARSECM = 3;
            
            fid = fopen( obj.fileName, 'r' );
            
            parseState = PARSESTATE_SEARCHSIGNALLINE;
            
            while ( true )
                line = fgets( fid );
                if ( false == ischar( line ) )
                    if ( PARSESTATE_SEARCHSIGNALLINE == parseState )
                        fclose( fid );
                        fid = fopen( obj.fileName, 'r' );
                        parseState = PARSESTATE_SEARCHSIGNALLINE_ALTERNATIVE;
                        continue;
                    end
                    
                    break;
                end
                
                if ( isempty( strtrim( line ) ) )
                    continue;
                end
                
                if ( PARSESTATE_SEARCHSIGNALLINE == parseState )
                    if ( 1 == strfind( line, SIGNAL_LINE ) )
                        parseState = PARSESTATE_PARSESTATISTICS;
                    end
                    
                elseif ( PARSESTATE_SEARCHSIGNALLINE_ALTERNATIVE == parseState )
                    if ( 1 == strfind( line, SIGNAL_LINE_ALTERNATIVE ) )
                        parseState = PARSESTATE_PARSESTATISTICS;
                    end
                    
                elseif ( PARSESTATE_PARSESTATISTICS == parseState )
                    if ( 1 == strfind( line, 'Correctly Classified Instances' ) )
                        s = strsplit( line );
                        result.corrAbs = str2double( s{ 4 } );
                        result.corrRel = str2double( s{ 5 } );
                        
                    elseif ( 1 == strfind( line, 'Incorrectly Classified Instances' ) )
                        s = strsplit( line );
                        result.incorrAbs = str2double( s{ 4 } );
                        result.incorrRel = str2double( s{ 5 } );
                        
                    elseif ( 1 == strfind( line, 'Kappa statistic' ) )
                        s = strsplit( line );
                        result.kappa = str2double( s{ 3 } );
                        
                    elseif ( 1 == strfind( line, 'Mean absolute error' ) )
                        s = strsplit( line );
                        result.meanAbsErr = str2double( s{ 4 } );
                        
                    elseif ( 1 == strfind( line, 'Root mean squared error' ) )
                        s = strsplit( line );
                        result.rmsErr = str2double( s{ 5 } );
                        
                    elseif ( 1 == strfind( line, 'Relative absolute error' ) )
                        s = strsplit( line );
                        result.relAbsErr = str2double( s{ 4 } );
                        
                    elseif ( 1 == strfind( line, 'Root relative squared error' ) )
                        s = strsplit( line );
                        result.rootRelSquaredErr = str2double( s{ 5 } );
                        
                    elseif ( 1 == strfind( line, 'Total Number of Instances' ) )
                        s = strsplit( line );
                        result.totalInstances = str2double( s{ 5 } );
                        
                    elseif ( 1 == strfind( line, '=== Confusion Matrix ===' ) )
                        parseState = PARSESTATE_PARSECM;
                    end
                    
                elseif ( PARSESTATE_PARSECM == parseState )
                    if ( isempty( strfind( line, '<-- classified as' ) ) )
                        s = strsplit( line );
                        
                        row = [];
                        
                        for i = 2 : length( s )
                            if ( s{ i }( 1 ) == '|' )
                                result.classes{ end + 1 } = s{ i + 3 };
                                break;
                            end
                            
                            row( i - 1 ) = str2double( s{ i } );
                        end
                        
                        result.cmAbs( end + 1, : ) = row;
                    end
                end
            end
            
            result.cmRel = obj.transformCMToRelative( result.cmAbs );
            
            fclose( fid );
            
        end
        
        function [ relativeCM ] = transformCMToRelative(obj, CM )
            relativeCM = CM;
            rowEventsCount = sum( CM, 2 );
            
            for i = 1 : length( rowEventsCount )
                relativeCM( i, : ) = CM( i, : ) / rowEventsCount( i );
            end
        end
    end
    
end

