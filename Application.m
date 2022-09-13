classdef Application < handle
    properties (Access = private, Constant)
        xmlFileName = 'DefaultSettings.xml';
    end    
    properties (Access = private)
        xmlData XMLData
    end
    
    properties (Dependent)
        FullInputFileName
        FullOutputFolderName
        FileNameSuffix
    end
    
    methods
        function newObj = Application()
        end
        function fullInputFileName = get.FullInputFileName(obj)
            fullInputFileName = GetFullInputFileName(obj);
        end
        function fullOutputFolderName = get.FullOutputFolderName(obj)
            fullOutputFolderName = GetFullOutputFolderName(obj);
        end
        function fileNameSuffix = get.FileNameSuffix(obj)
            fileNameSuffix =  obj.xmlData.FileNameSuffix;            
        end
        
    end
   
    methods (Access = public)
        function obj = Run(obj)
            PrepereApplicationConfig(obj);
            
            
            g = 1;
        end
    end
    
    methods (Access = private)
        function PrepereApplicationConfig(obj)
            AddPaths(obj);
            LoadSettingsFromXML(obj);
            MakeOutputFolder(obj);
            MakeInstanceOfApplicationConfig(obj);
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
        function obj = MakeInstanceOfApplicationConfig(obj)
            appConfig = ApplicationConfig.Instance();
            appConfig.SetSettings(obj);
        end

        function obj = LoadSettingsFromXML(obj)
            xmlReader = XMLReader(obj.xmlFileName);
            obj.xmlData = xmlReader.ReadXML();
        end
        
        function fullInputFileName = GetFullInputFileName(obj)
            fullInputFileName = [obj.xmlData.BeginInputFileName obj.xmlData.InputFileName];
        end
        function fullOutputFolderName = GetFullOutputFolderName(obj)
            fullOutputFolderName = [obj.xmlData.BeginOutputFolderName obj.xmlData.OutputFolderName];
        end
        function MakeOutputFolder(obj)
            fullOutputFolderName = GetFullOutputFolderName(obj);
            mkdir(fullOutputFolderName);
        end
        
    end
end