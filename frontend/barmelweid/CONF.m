classdef CONF
    % Encapsulates some common configuration parameters
    %   
    
    properties(Constant)
        DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\';
        
        PATIENTS_DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\';
        ALL_PATIENTS_DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\all\';

        WEKA_PATH = 'C:\Program Files\Weka-3-8';
                
        RAW_DATA_SUBFOLDER = '1_raw';
        PREPROCESSED_DATA_SUBFOLDER = '2_preprocessed';
        DBN_DATA_SUBFOLDER = '3_dbn';
        WEKA_DATA_SUBFOLDER = '4_weka';
        
        ALL_PATIENTS_PREPROCESSED_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.PREPROCESSED_DATA_SUBFOLDER '\' ];
        ALL_PATIENTS_DBN_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.DBN_DATA_SUBFOLDER '\' ];
        ALL_PATIENTS_WEKA_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.WEKA_DATA_SUBFOLDER '\' ];
        
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
        
        function outputPath = getOutputPathWithTimestamp()
            outputPath = [ CONF.getOutputPath() '\' datestr(now,'yyyy-mm-dd_HH-MM-SS')];
        end
        
        function outputPath = getRawDataOutputPath()
            outputPath = [ CONF.ALL_PATIENTS_DATA_PATH 'results\DBN_rawdata' ];
        end
        
        function outputPath = getRawDataOutputPathWithTimestamp()
            outputPath = [ CONF.getRawDataOutputPath() '\' datestr(now,'yyyy-mm-dd_HH-MM-SS') ];
        end        
        
    
    end

end
