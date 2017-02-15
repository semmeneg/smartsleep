classdef CONF
    % Encapsulates some common configuration parameters
    %   
    
    properties(Constant)
        BASE_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\';
        BASE_DATA_PATH = [CONF.BASE_PATH 'RawData\'];
        BASE_OUTPUT_PATH = [CONF.BASE_PATH 'Processed\'];

        WEKA_PATH = 'C:\Program Files\Weka-3-8';
                
        RAW_DATA_SUBFOLDER = '1_raw';
        PREPROCESSED_DATA_SUBFOLDER = '2_preprocessed';
        DBN_DATA_SUBFOLDER = '3_dbn';
        WEKA_DATA_SUBFOLDER = '4_weka';
        
        %data sources and combinations
        EEG = 'EEG';
        MSR = 'MSR';
        ZEPHYR = 'ZEPHYR';
        MSR_ZEPHYR = 'MSR_ZEPHYR';
        EEG_MSR = 'EEG_MSR';
        EEG_ZEPHYR = 'EEG_ZEPHYR';
        EEG_MSR_ZEPHYR = 'EEG_MSR_ZEPHYR';
    end
    
    methods(Static)
        function setupJava()
            
            % Set Java 
            JAVA = 'C:\Program Files\Java\';
            javaFolders = dir([JAVA 'jdk*']);
            if(size(javaFolders, 1)== 0)
                error(['No Java installation found under: ' JAVA]); 
            end
             [tmp ind]=sort({javaFolders.name});
            javaFolders=javaFolders(ind);
            setenv('JAVA_HOME', [JAVA javaFolders(end).name]);
            setenv('PATH', [JAVA javaFolders(end).name '\bin']);
        end
        
    end

end
