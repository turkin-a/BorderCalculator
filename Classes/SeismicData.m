classdef SeismicData < handle & matlab.mixin.Copyable
    properties (Access = private)
        seismograms (:,1) Seismogram
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

    methods(Access = protected)
      % Override copyElement method:
      function cpObj = copyElement(obj)
         % Make a shallow copy of all four properties
         cpObj = copyElement@matlab.mixin.Copyable(obj);
         % Make a deep copy of the seismograms object
         for i = 1:1:length(obj.seismograms)
             cpObj.seismograms(i) = copy(obj.seismograms(i));
         end
      end
    end

    methods (Access = public, Static)
        function outputSeismicData = BuildSeismicData(seismicDataFromMatFile)
            outputSeismicData = SeismicData();
            outputSeismicData.NumberSamplesPerSec = seismicDataFromMatFile.discret;
            outputSeismicData.NumberOfSamplesPerTrace = seismicDataFromMatFile.SampPerTrace;
            numberOfSeis = length(seismicDataFromMatFile.Seis);
            seismograms(1:numberOfSeis,1) = Seismogram();
            for i = 1:1:numberOfSeis
                curSeisData = seismicDataFromMatFile.Seis{i};
                curSourceX = seismicDataFromMatFile.mDetonX(i);
                curSensorsX = seismicDataFromMatFile.mXd{i};
                seismogram = Seismogram.BuildSeismogram(curSeisData, curSourceX, curSensorsX);
                seismograms(i,1) = seismogram;
            end
            outputSeismicData.Seismograms = seismograms;
        end
    end
end

