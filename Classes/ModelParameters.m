classdef ModelParameters  < ISingleton
    properties (Access = private)
        isCalculatePreparedInputSeismicData = true
    end
    
    properties (Dependent, SetAccess = private)
        IsCalculatingPreparedInputSeismicData
    end
    
    methods
        function newObj = ModelParameters()
        end
    end

    methods
        function isCalculatePreparedInputSeismicData = get.IsCalculatingPreparedInputSeismicData(obj)
            isCalculatePreparedInputSeismicData = obj.isCalculatePreparedInputSeismicData;
        end
        function set.IsCalculatingPreparedInputSeismicData(obj, isCalculatePreparedInputSeismicData)
            if ischar(isCalculatePreparedInputSeismicData)
                isCalculatePreparedInputSeismicData = str2double(isCalculatePreparedInputSeismicData);
            end
            obj.isCalculatePreparedInputSeismicData = isCalculatePreparedInputSeismicData;
        end
    end
        
    methods (Access = public)
        function obj = SetSettings(obj, xmlData)
            fieldNames = fieldnames(xmlData);
            for i = 1:1:length(xmlData)
                fieldName = fieldNames{i};
                obj.(fieldName) = xmlData.(fieldName);
            end
        end
    end
    methods (Access = private)

    end

    methods(Static)
      function obj = Instance()
         persistent uniqueInstance
         if isempty(uniqueInstance)
            obj = ModelParameters();
            uniqueInstance = obj;
         else
            obj = uniqueInstance;
         end
      end
   end
end