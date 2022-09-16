classdef SeismicData < handle & matlab.mixin.Copyable
    properties (Access = private)
        seismograms cell = []
        numberOfSeismograms double {mustBeNonnegative(numberOfSeismograms)}
        numberOfSamplesPerSec double {mustBeNonnegative(numberOfSamplesPerSec)}
        numberOfSamplesPerTrace double {mustBeNonnegative(numberOfSamplesPerTrace)}
    end

    properties (Dependent)
        Seismograms
        NumberOfSeismograms
        NumberSamplesPerSec
        NumberOfSamplesPerTrace
    end

    methods
        function set.NumberSamplesPerSec(obj, numberOfSamplesPerSec)
            obj.numberOfSamplesPerSec = numberOfSamplesPerSec;
        end
        function numberOfSamplesPerSec = get.NumberSamplesPerSec(obj)
            numberOfSamplesPerSec = obj.numberOfSamplesPerSec;
        end

        function set.NumberOfSamplesPerTrace(obj, numberOfSamplesPerTrace)
            obj.numberOfSamplesPerTrace = numberOfSamplesPerTrace;
        end
        function numberOfSamplesPerTrace = get.NumberOfSamplesPerTrace(obj)
            numberOfSamplesPerTrace = obj.numberOfSamplesPerTrace;
        end

        function set.Seismograms(obj, seismograms)
            obj.seismograms = seismograms;
            obj.numberOfSeismograms = length(seismograms);
        end
        function seismograms = get.Seismograms(obj)
            seismograms = obj.seismograms;
        end

        function numberOfSeismograms = get.NumberOfSeismograms(obj)
            numberOfSeismograms = obj.numberOfSeismograms;
        end
    end

    methods (Access = public)
        
%         % Нормализовать сейсмические данные
%         function obj = Normalization(obj, sizeOfHalfWindow)
%             for i = 1:1:length(obj.Seismograms)
%                 seismogram = obj.Seismograms{i};
% 
%                 seismogram.Normalization(sizeOfHalfWindow);
%                 firstTimes = seismogram.FirstTimes;
%                 obj.seismograms{i} = seismogram;
%             end
%         end
    end
    methods (Access = public, Static)
        function outputSeismicData = BuildSeismicData(seismicDataFromMatFile)
            outputSeismicData = SeismicData();
            outputSeismicData.NumberSamplesPerSec = seismicDataFromMatFile.discret;
            outputSeismicData.NumberOfSamplesPerTrace = seismicDataFromMatFile.SampPerTrace;
            numberOfSeis = length(seismicDataFromMatFile.Seis);
            seismograms = cell(1, numberOfSeis);
            for i = 1:1:numberOfSeis
                curSeisData = seismicDataFromMatFile.Seis{i};
                curSourceX = seismicDataFromMatFile.mDetonX(i);
                curSensorsX = seismicDataFromMatFile.mXd{i};
                seismogram = Seismogram.BuildSeismogram(curSeisData, curSourceX, curSensorsX);
                seismograms{i} = seismogram;
            end
            outputSeismicData.Seismograms = seismograms;
        end
    end
end

