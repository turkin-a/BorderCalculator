classdef DataVisualizer < IVisualizer
    properties (Access = private)
        figureObject matlab.ui.Figure
        numberOfFigure (1,1) double = 1
        titleName (1,:) char = []
        labelXName (1,:) char = []
        labelYName (1,:) char = []
    end

    methods (Access = private)
        function obj = DataVisualizer()
        end

        function UpdateFigure(obj)
            curFigureObject = GetFigureObject(obj);
            activeFigureObject = gcf;
            if ~isempty(activeFigureObject) && curFigureObject ~= activeFigureObject
                figure(curFigureObject);
                cla;
            end
            hold on;
        end

        function figureObject = GetFigureObject(obj)
            if IsFigureObjectExist(obj)
                figureObject = obj.figureObject;
            else
                obj.figureObject = figure(obj.numberOfFigure);
                figureObject = obj.figureObject;
            end
        end
        function result = IsFigureObjectExist(obj)
            result = false;
            if ~isempty(obj.figureObject) && isvalid(obj.figureObject) && isgraphics(obj.figureObject)
                result = true;
            end
        end

        
    end

    methods (Access = public, Static)
        function SetNumberOfFigure(numberOfFigure)
            obj = DataVisualizer.Instance();
            obj.numberOfFigure = numberOfFigure;
            obj.figureObject = figure(obj.numberOfFigure);
            hold on;
        end
        function numberOfFigure = GetNumberOfFigure()
            obj = DataVisualizer.Instance();
            numberOfFigure = obj.numberOfFigure;
        end

        function SetTitle(titleName)
            obj = DataVisualizer.Instance();
            obj.titleName = titleName;
        end

        function SetLabelX(labelXName)
            obj = DataVisualizer.Instance();
            obj.labelXName = labelXName;
        end

        function SetLabelY(labelYName)
            obj = DataVisualizer.Instance();
            obj.labelYName = labelYName;
        end

        function PlotSeismogram(seismogram, tipLineAndColor, lineWidth)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            traces = seismogram.Traces; 
            DataVisualizer.PlotTraces(traces, tipLineAndColor, lineWidth);
        end

        function PlotTraces(traces, tipLineAndColor, lineWidth)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            for indexOfTrace = 1:1:length(traces)
                trace = traces(indexOfTrace);
                DataVisualizer.PlotTrace(trace, indexOfTrace, tipLineAndColor, lineWidth);
            end
        end

        function PlotTrace(trace, indexOfTrace, tipLineAndColor, lineWidth)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            samples = trace.Samples;
            DataVisualizer.PlotSamples(samples, indexOfTrace, tipLineAndColor, lineWidth);
        end
        
        function PlotSamples(samples, indexOfTrace, tipLineAndColor, lineWidth)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            x = 1:1:length(samples);    
            amplitude = max(abs(samples));
            if amplitude == 0
                amplitude = 1;
            end
            plot(samples / (2*amplitude) + indexOfTrace, -x, tipLineAndColor, 'LineWidth', lineWidth);
        end

        function obj = Instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = DataVisualizer();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end

        function obj = Clear()
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            cla;
            hold on;
            if ~isempty(obj.titleName)
                title(obj.titleName);
            end
            if ~isempty(obj.labelXName)
                xlabel(obj.labelXName);
            end
            if ~isempty(obj.labelYName)
                ylabel(obj.labelYName);
            end
        end        
    end
end