classdef Validator    
    methods(Access = public, Static)
        function MustBeTypeOf(value, typeClass)
            if ~isempty(value)
                if isa(value, typeClass) == false
                    msgID = 'SeismicDataFileReader:CouldNotReadFile';
                    msgtext = ['Value must inherit class: ' typeClass];
                    ME = MException(msgID,msgtext);
                    throw(ME);
                end
            end
        end
    end
end


