classdef TestApplication < handle
    methods
        function obj = TestApplication()
        end        
    end

    methods (Access = public)
        function obj = Run(obj)
            AddPaths(obj);
            RunXMLFileTest(obj);
            RunSeismicTraceTest(obj);
            RunSeismogramTest(obj);
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