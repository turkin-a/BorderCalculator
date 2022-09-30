classdef AnalyticalSignal < handle
    properties (Access = private)
        correctedSeismicData
        hilbertSeismicData
        correctedAbsHilbertSeismicData
        momentaryPhaseSeismicData
    end

    properties (Dependent)
        CorrectedSeismicData
        HilbertSeismicData
        CorrectedAbsHilbertSeismicData
        MomentaryPhaseSeismicData
    end

    methods
        function correctedSeismicData = get.CorrectedSeismicData(obj)
            correctedSeismicData = obj.correctedSeismicData;
        end
        function set.CorrectedSeismicData(obj, correctedSeismicData)
            obj.correctedSeismicData = correctedSeismicData;
        end

        function hilbertSeismicData = get.HilbertSeismicData(obj)
            hilbertSeismicData = obj.hilbertSeismicData;
        end
        function set.HilbertSeismicData(obj, hilbertSeismicData)
            obj.hilbertSeismicData = hilbertSeismicData;
        end

        function correctedAbsHilbertSeismicData = get.CorrectedAbsHilbertSeismicData(obj)
            correctedAbsHilbertSeismicData = obj.correctedAbsHilbertSeismicData;
        end
        function set.CorrectedAbsHilbertSeismicData(obj, correctedAbsHilbertSeismicData)
            obj.correctedAbsHilbertSeismicData = correctedAbsHilbertSeismicData;
        end

        function momentaryPhaseSeismicData = get.MomentaryPhaseSeismicData(obj)
            momentaryPhaseSeismicData = obj.momentaryPhaseSeismicData;
        end
        function set.MomentaryPhaseSeismicData(obj, momentaryPhaseSeismicData)
            obj.momentaryPhaseSeismicData = momentaryPhaseSeismicData;
        end
    end

end