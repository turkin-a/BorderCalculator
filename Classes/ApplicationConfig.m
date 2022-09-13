classdef ApplicationConfig < ISingleton
    properties (Access = private)
        fullInputFileName (1,:) char = []
        fullOutputFolderName (1,:) char = []
        fileNameSuffix (1,:) char = []
        modelParametersFileName = [] % 'DefaultModelParameters.xml'
    end
        
    properties (Dependent, SetAccess = private)
        FullInputFileName
        FullOutputFolderName
        FileNameSuffix
        ModelParametersFileName
    end
    
    methods
        function fullInputFileName = get.FullInputFileName(obj)
            fullInputFileName = obj.fullInputFileName;
        end

        function fullOutputFolderName = get.FullOutputFolderName(obj)
            fullOutputFolderName = obj.fullOutputFolderName;
        end

        function fileNameSuffix = get.FileNameSuffix(obj)
            fileNameSuffix =  obj.fileNameSuffix;            
        end

        function modelParametersFileName = get.ModelParametersFileName(obj)
            modelParametersFileName =  obj.modelParametersFileName;            
        end
    end
    
    methods(Access = private)
      function newObj = ApplicationConfig()
      end
    end
    
    methods (Access = public)
        function obj = SetSettings(obj, xmlData)
            obj.fullInputFileName = xmlData.GetFullInputFileName();
            obj.fullOutputFolderName = xmlData.GetFullOutputFolderName();
            obj.fileNameSuffix = xmlData.FileNameSuffix;
            obj.modelParametersFileName = xmlData.ModelParametersFileName;
        end
    end
    
    methods(Static)
      function obj = Instance()
         persistent uniqueInstance
         if isempty(uniqueInstance)
            obj = ApplicationConfig();
            uniqueInstance = obj;
         else
            obj = uniqueInstance;
         end
      end
   end
    
    
end