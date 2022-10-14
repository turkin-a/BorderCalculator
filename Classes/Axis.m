classdef Axis < handle
    properties (Access = private)
    end

    properties (Dependent)
    end

    methods
    end

    methods(Access = public, Static)
        function times = GetTimesByH_Fi_V(h, fi, v, Li, dt)
            times = sqrt( Li.^2 + 4*h^2 + 4*Li*h*sind(fi)) / (v) / dt;
        end

        function times = GetTimesByAxisParams(axisParameters, Li, dt)
            times = Axis.GetTimesByH_Fi_V(axisParameters.H, ...
                                     axisParameters.Fi, ...
                                     axisParameters.V, ...
                                     Li, ...
                                     dt);
        end

    end
end