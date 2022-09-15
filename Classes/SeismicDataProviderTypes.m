classdef(Enumeration) SeismicDataProviderTypes < int32
    enumeration
        NotDetermined(0)
        MatSeismicDataProviderType(1)
        SegYSeismicDataProviderType(2)
    end
    methods(Access = public, Static)
        function resultType = GetTypeByName(name)
            switch name
                case 'MatSeismicDataProviderType'
                    resultType = SeismicDataProviderTypes.MatSeismicDataProviderType;
                case 'SegYSeismicDataProviderType'
                    resultType = SeismicDataProviderTypes.SegYSeismicDataProviderType;
            end
        end
    end
end

