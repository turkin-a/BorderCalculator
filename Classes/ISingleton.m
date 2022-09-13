classdef ISingleton < handle
   properties(Access = private)
   end
   
   methods(Abstract, Static)
      obj = Instance();
   end
   
   methods
   end
end