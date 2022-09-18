classdef Validator
    methods(Access = public, Static)
        function MustBeTypeOf(value, classType)
            if ~isempty(value)
                if isa(value, classType) == false
                    msgID = 'Validator:MustBeTypeOf:WrongClassTyp';
                    msgtext = ['Value must inherit class: ' classType];
                    ME = MException(msgID,msgtext);
                    throw(ME);
                end
            end
        end
    end
end


