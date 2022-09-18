classdef(Abstract) IVisualizer < ISingleton
    properties(Access = public, Abstract)
    end

    methods(Static, Abstract)
    end

    methods(Access = public, Abstract)
        SetNumberOfFigure(numberOfFigure);
        numberOfFigure = GetNumberOfFigure();
        SetTitle(titleName);
        SetLabelX(labelXName);
        SetLabelY(labelYName);
        PlotSeismogram(seismogram, tipLineAndColor, lineWidth);
        PlotTraces(traces, tipLineAndColor, lineWidth);
        PlotTrace(trace, indexOfTrace, tipLineAndColor, lineWidth);
        PlotSamples(samples, indexOfTrace, tipLineAndColor, lineWidth);
        Clear();
    end
end