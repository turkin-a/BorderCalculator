classdef SeismicDataFileReader < IFileReader
    properties(Access = private)
        fileName (1,:) char = []
    end

    methods(Access = public)
        function obj = SeismicDataFileReader(fileName)
            obj.fileName = fileName;
        end 

        function outputSeismicData = Read(obj)
            loadResult = load(obj.fileName);
            if isempty(loadResult)
                msgID = 'SeismicDataFileReader:CouldNotReadFile';
                msgtext = ['Unable to read file ' strrep(obj.fileName, '\', '\\') '. SeismicDataFileReader:FileOpenError.'];
                ME = MException(msgID,msgtext);
                throw(ME);
            end
            outputSeismicData = GetOutputSeismicData(obj, loadResult);
        end
    end

    methods(Access = private)
        function outputSeismicData = GetOutputSeismicData(obj, loadResult)
            outputSeismicData = SeismicData();
            outputSeismicData.SamplingPerSec = loadResult.discret;
            outputSeismicData.SamplingPerTrace = loadResult.SampPerTrace;
            countSeis = length(loadResult.Seis);
            seismograms = cell(1, countSeis);
            for i = 1:1:countSeis
                curSeisData = loadResult.Seis{i};
                curSourceX = loadResult.mDetonX(i);
                curSensorsX = loadResult.mXd{i};
                seismogram = BuildSeismogram(obj, curSeisData, curSourceX, curSensorsX);
                seismograms{i} = seismogram;
            end
            outputSeismicData.Seismograms = seismograms;
        end
        function seismogram = BuildSeismogram(obj, curSeisData, curSourceX, curSensorsX)
            seismogram = Seismogram.BuildSeismogram(curSeisData, curSourceX, curSensorsX);
        end
    end
end