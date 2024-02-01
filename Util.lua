local Util = {}

Meeting.Util = Util

function Util:StringStarts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

function Util:StringSplit(str, delimiter)
    if not str then
        return nil
    end
    local delimiter, fields = delimiter or ":", {}
    local pattern = string.format("([^%s]+)", delimiter)
    string.gsub(str, pattern, function(c)
        fields[table.getn(fields) + 1] = c
    end)
    return unpack(fields)
end

function string.isempty(s)
    return s == nil or s == ''
end
