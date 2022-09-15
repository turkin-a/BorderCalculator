classdef TestApplication < handle
    methods
        function obj = TestApplication()
        end        
    end

    methods (Access = public)
        function obj = Run(obj)
            AddPaths(obj);

            xmlFileTest = XMLFileTest();
            resultXMLFileTest = run(xmlFileTest);
            table(resultXMLFileTest)
        end
    end

    methods (Access = private)
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