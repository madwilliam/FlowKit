function CM_STR_ARRAY_TO_WS (Str_Array)

if (isempty(Str_Array))
Str_Array=CM_uigetvar ('cell','Get Structure to analyse');
end

for counter=1:1:size(Str_Array,2)
    temp_Struct=Str_Array {counter};
    CM_STR_TO_WS (temp_Struct);
end

end


function CM_STR_TO_WS(temp_Struct)
names = fieldnames(temp_Struct);

for counter=1:1:size(names,1)
    field_name= char(names (counter));
    assignin('base',field_name,temp_Struct.(field_name));
end
end

