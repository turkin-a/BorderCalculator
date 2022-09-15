classdef IFileReader < handle    
    methods(Access = public, Abstract)
        outputData = Read(obj);
    end
end