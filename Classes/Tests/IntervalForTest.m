classdef IntervalForTest < Interval

    methods
        function obj = IntervalForTest(interval)
            obj = obj@Interval(interval.BeginTime, ...
                               interval.EndingTime, ...
                               interval.indexOfTrace, ...
                               0.001);
        end

        function CalculateTypeByHilbertTest(obj, traceOfHilbert)
            CalculateTypeByHilbert(obj, traceOfHilbert);
        end
    end
end