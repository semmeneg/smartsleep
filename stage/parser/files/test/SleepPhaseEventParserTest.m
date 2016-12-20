% SleepPhaseEventParserTest
%
% Tests reader of event files with labeled sleep phases.
%
classdef SleepPhaseEventParserTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        txtEventFile = {[CONF.BASE_DATA_PATH 'UnitTest\parser\*-Events.txt' ]};
        docxDerrivedEventFile = {[CONF.BASE_DATA_PATH 'UnitTest\parser\events_docx.txt ' ]};
    end
    
    
    methods (Test)
        %% Tests reading different formatted event files.
        function testSleepPhaseEventParser(testCase, txtEventFile, docxDerrivedEventFile) 
            
            % test with text based event file
            sleepPhaseParser = SleepPhaseEventParser(txtEventFile);
            events = sleepPhaseParser.run();
            testCase.assertNotEmpty(events);
            
            % test with event file derrived from docx (word) file
            sleepPhaseParser = SleepPhaseEventParser(docxDerrivedEventFile);
            events = sleepPhaseParser.run();
            testCase.assertNotEmpty(events);
            
        end
    end
end

