classdef LifeTimeROI
   methods (Static)
       function [hex_uuid,int64_uuid] = make_uuid()
           int64_uuid = typecast(randi(intmax('uint32'),2,1,'uint32'),'uint64');
           hex_uuid = dec2hex(int64_uuid);
       end

   end
end