classdef(Enumeration) SeismicDataProviderTypes < int32
    enumeration
        MatSeismicDataProviderType(0)
        SegYSeismicDataProviderType(1)
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

