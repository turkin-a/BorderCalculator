classdef Application < handle
    properties (Access = private, Constant)
        xmlApplicationConfigFileName (1,:) char = 'DefaultApplicationConfig.xml'
    end
    properties (Access = private)
        seismicDataProcessor (1,1) ISeismicDataProcessor = SeismicDataProcessor()
    end
    
    properties (Dependent)
    end
    
    methods
        function obj = Application()
        end
    end
   
    methods (Access = public)
        function obj = Run(obj)
            PrepereApplicationConfig(obj);
            PrepereModelParameters(obj);
            obj.seismicDataProcessor.Calculate();
        end
    end
    
    methods (Access = private)
        function PrepereApplicationConfig(obj)
            obj.AddPaths();
            xmlData = LoadApplicationConfigFromXML(obj);
            MakeOutputFolder(obj, xmlData);
            MakeInstanceOfApplicationConfig(obj, xmlData);
        end
        function PrepereModelParameters(obj)
            xmlData = LoadModelParametersFromXML(obj);
            MakeInstanceOfModelParameters(obj, xmlData);   
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
        function obj = MakeInstanceOfApplicationConfig(obj, xmlData)
            applicationConfig = ApplicationConfig.Instance();
            applicationConfig.SetSettings(xmlData);
        end
        function obj = MakeInstanceOfModelParameters(obj, xmlData)
            modelParameters = ModelParameters.Instance();
            modelParameters.SetSettings(xmlData);
        end

        function xmlData = LoadApplicationConfigFromXML(obj)
            xmlReader = XMLReader(obj.xmlApplicationConfigFileName);
            xmlData = xmlReader.ReadApplicationConfig();
        end
        function MakeOutputFolder(obj, xmlData)
            fullOutputFolderName = xmlData.GetFullOutputFolderName();
            mkdir(fullOutputFolderName);
        end
        function xmlData = LoadModelParametersFromXML(obj)
            applicationConfig = ApplicationConfig.Instance();
            xmlReader = XMLReader(applicationConfig.ModelParametersFileName);
            xmlData = xmlReader.ReadModelParameters();
        end
        
    end
end