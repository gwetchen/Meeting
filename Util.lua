function string.startswith(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

function string.isempty(s)
    return s == nil or s == ''
end
