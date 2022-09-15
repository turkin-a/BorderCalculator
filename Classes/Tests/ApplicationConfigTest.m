classdef ApplicationConfigTest < ApplicationConfig
    methods (Access = public)
        function obj = ApplicationConfigTest()
        end
    end
    methods (Access = public, Static)
        function obj = GetNewInstance()
            obj = ApplicationConfigTest();
        end
    end
end