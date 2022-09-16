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
        function outputSeismicData = GetOutputSeismicData(obj, seismicDataFromMatFile)
            outputSeismicData = SeismicData.BuildSeismicData(seismicDataFromMatFile);
        end
        function seismogram = BuildSeismogram(obj, curSeisData, curSourceX, curSensorsX)
            seismogram = Seismogram.BuildSeismogram(curSeisData, curSourceX, curSensorsX);
        end
    end
end