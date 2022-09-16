classdef(Abstract) ISingleton < handle & matlab.mixin.Heterogeneous
    properties(Access = public)
    end

    methods(Abstract, Static)
        obj = Instance();
    end

    methods(Access = public)
    end
end