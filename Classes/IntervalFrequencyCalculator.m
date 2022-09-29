classdef IntervalFrequencyCalculator < handle
    properties
        beginTime (1,1) double
        endingTime (1,1) double
        typeOfInterval (1,1) IntervalType
    end

    methods
        function obj = IntervalFrequencyCalculator()
        end

        function frequency = Calculate(obj, interval, trace)
            obj.beginTime = interval.BeginTime;
            obj.endingTime = interval.EndingTime;
            obj.typeOfInterval = interval.TypeOfInterval;
            frequency = CalculateFrequencyForInterval(obj, trace);
        end
    end

    methods (Access = private)
        function frequency = CalculateFrequencyForInterval(obj, trace)
            frequency = 0;
            signal = trace.Samples(obj.beginTime:obj.endingTime);
            hilbSignal = hilbert(signal);
            W = GetW(obj, signal, hilbSignal);
            W_average0 = GetW_Average(obj, W, 1, length(W), hilbSignal);
            freq_average0 = W_average0 / (2 * pi) *1000;            
            delt_W = GetDeltW(obj, hilbSignal, W, W_average0);
            frequencies = W / (2 * pi) * 1000;  
            if DoesArrayContainNegativeFreqInCenter(obj, frequencies) == true
                return;
            end
            frequencyTube = delt_W / (2 * pi) * 1000;
            % Устранение выбросов
            correctedFrequencies = CorrectFrequencies(obj, frequencies, freq_average0, frequencyTube);
            % Предварительная частота
            preliminaryFrequency = GetPreliminaryFrequency(obj, correctedFrequencies);
            % Уточнение предварительной частоты в трубе
            [tBeg, tEnd] = GetFrequencyTimeIntervalFromTube(obj, correctedFrequencies, preliminaryFrequency, frequencyTube);
            W_average = GetW_Average(obj, W, tBeg, tEnd, hilbSignal);
            freq_average = W_average / (2 * pi) *1000;      
            frequency = freq_average;
        end
        function W = GetW(obj, signal, hilbSignal)
            x = signal;
            y = imag(hilbSignal);
            yp = diff(y);
            xp = diff(x);
            for t = 1:1:length(yp)
                W(t) = ( ( yp(t) * x(t) - y(t) * xp(t) ) / ( (x(t))^2 + (y(t))^2 ) );
            end
        end
        function W_average = GetW_Average(obj, W, tBeg, tEnd, hilbSignal)
            tmp1 = 0;
            tmp2 = 0;
            for t = tBeg:1:tEnd
                tmp1 = tmp1 + W(t) * (abs(hilbSignal(t)))^2;
                tmp2 = tmp2 + (abs(hilbSignal(t)))^2;
            end            
            W_average = tmp1 / tmp2;
        end
        function delt_W = GetDeltW(obj, hilbSignal, W, W_average0)
            A = abs(hilbSignal);
            tmp1 = 0;            
            tmp2 = 0;
            for t = 1:1:length(W) 
                tmp1 = tmp1 + (W(t) - W_average0)^2 * (A(t))^2;
                tmp2 = tmp2 + (A(t))^2;
            end
            delt_W = sqrt(tmp1 / tmp2);
        end
        function result = DoesArrayContainNegativeFreqInCenter(obj, frequencies)
            result = false;
            sz = length(frequencies);
            iBeg = round(sz*1/3);
            iEnd = round(sz*2/3);
            if min(frequencies(iBeg:iEnd)) < 0
                result = true;
            end
        end
        function frequencies = CorrectFrequencies(obj, frequencies, preliminaryFrequency, frequencyTube)
            minFreq = preliminaryFrequency - frequencyTube;
            maxFreq = preliminaryFrequency + frequencyTube;
            iCentr = round( length(frequencies)/2 );            
            if frequencies(iCentr) > maxFreq || frequencies(iCentr) < minFreq
                [tBeg, tEnd] = GetIntervalTimesOfGoodFreq(obj, frequencies, minFreq, maxFreq);
                for t = tBeg:1:tEnd
                    if frequencies(t) > maxFreq
                        frequencies(t) = maxFreq;
                    elseif frequencies(t) < minFreq
                        frequencies(t) = minFreq;
                    end
                end
            end
        end
        function preliminaryFrequency = GetPreliminaryFrequency(obj, frequencies)
            sz = length(frequencies);
            tBeg = round(sz *1/8);
            tEnd = round(sz *7/8);
            preliminaryFrequency = median(frequencies(tBeg:tEnd));
        end
        function [tBeg, tEnd] = GetFrequencyTimeIntervalFromTube(obj, frequencies, preliminaryFrequency, frequencyTube)
            minFreq = preliminaryFrequency - frequencyTube;
            maxFreq = preliminaryFrequency + frequencyTube;
            [tBeg, tEnd] = GetIntervalTimesOfGoodFreq(obj, frequencies, minFreq, maxFreq);
        end
        function [tBeg, tEnd] = GetIntervalTimesOfGoodFreq(obj, frequencies, minFreq, maxFreq)
            iCentr = round( length(frequencies)/2 );
            tBeg = iCentr;
            tEnd = iCentr;
            for i = iCentr-1:-1:1
                curFreq = frequencies(i);
                nextFreq = frequencies(i+1);
                if (nextFreq < minFreq || nextFreq > maxFreq) && ...
                   (curFreq >= minFreq && curFreq <= maxFreq)
                   break;
                end
                tBeg = i;
            end
            for i = iCentr+1:1:length(frequencies)
                curFreq = frequencies(i);
                prevFreq = frequencies(i-1);
                if (prevFreq < minFreq || prevFreq > maxFreq) && ...
                   (curFreq >= minFreq && curFreq <= maxFreq)
                   break;
                end
                tEnd = i;
            end
        end
    end
end