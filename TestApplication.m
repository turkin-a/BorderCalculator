classdef TestApplication < handle
    methods
        function obj = TestApplication()
        end

        function obj = Run(obj)
            AddPaths(obj);

            RunXMLFileTest(obj);
            RunSeismicTraceTest(obj);
            RunSeismogramTest(obj);
            RunSeismicDataTest(obj);
            RunSeismicDataFileReaderTest(obj);
            RunDirectWaveCalculatorTest(obj);
            RunIntervalTest(obj);
        end
    end

    methods (Access = private)
        function RunXMLFileTest(obj)
            xmlFileTest = XMLFileTest();
            resultXMLFileTest = run(xmlFileTest);
            table(resultXMLFileTest)
        end

        function RunSeismicTraceTest(obj)
            seismicTraceTest = SeismicTraceTest();
            resultSeismicTraceTest = run(seismicTraceTest);
            table(resultSeismicTraceTest)
        end
        function RunSeismogramTest(obj)
            seismogramTest = SeismogramTest();
            resultSeismogramTest = run(seismogramTest);
            table(resultSeismogramTest)
        end
        function RunSeismicDataTest(obj)
            seismicDataTest = SeismicDataTest();
            resultSeismicDataTest = run(seismicDataTest);
            table(resultSeismicDataTest)
        end
        function RunSeismicDataFileReaderTest(obj)
            seismicDataFileReaderTest = SeismicDataFileReaderTest();
            resultSeismicDataFileReaderTest = run(seismicDataFileReaderTest);
            table(resultSeismicDataFileReaderTest)
        end
        function RunDirectWaveCalculatorTest(obj)
            directWaveCalculatorTest = DirectWaveCalculatorTest();
            resultDirectWaveCalculatorTest = run(directWaveCalculatorTest);
            table(resultDirectWaveCalculatorTest)
        end
        function RunIntervalTest(obj)
            intervalTest = IntervalTest();
            resultIntervalTest = run(intervalTest);
            table(resultIntervalTest)
        end


        function obj = AddPaths(obj)
            AddPathsOfClasses(obj);
        end
        function obj = AddPathsOfClasses(obj)
            folderOfClassesName = GetFolderOfClassesName(obj);
            pathsOfSubDirectories = genpath(folderOfClassesName);
            addpath(pathsOfSubDirectories);
        end
        function folderOfClassesName = GetFolderOfClassesName(obj)
            workPath = GetWorkPath(obj);
            folderOfClassesName = [workPath '\Classes'];
        end
        function workPath = GetWorkPath(obj)
            workPath = cd('.');
        end
    end
end