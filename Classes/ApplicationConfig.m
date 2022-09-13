classdef ApplicationConfig < ISingleton
    properties (Access = private)
        fullInputFileName = []
        fullOutputFolderName = []
        fileNameSuffix = []
    end
        
    properties (Dependent)
        FullInputFileName
        FullOutputFolderName
        FileNameSuffix
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
    end
    
    methods(Access = private)
      function newObj = ApplicationConfig()
      end
    end
    
    methods (Access = public)
        function obj = SetSettings(obj, applicationConfig)
            obj.fullInputFileName = applicationConfig.FullInputFileName;
            obj.fullOutputFolderName = applicationConfig.FullOutputFolderName;
            obj.fileNameSuffix = applicationConfig.FileNameSuffix;
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