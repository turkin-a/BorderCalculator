classdef(Abstract) IFileReader < handle & matlab.mixin.Heterogeneous
    methods(Access = public, Abstract)
        outputData = Read(obj);
    end
end