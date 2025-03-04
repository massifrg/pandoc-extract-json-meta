local pandoc = pandoc
local Pandoc = pandoc.Pandoc
local Plain = pandoc.Plain
local pandocType = pandoc.utils.type
local info = pandoc.log.info
local warn = pandoc.log.warn
local string_gsub = string.gsub
local string_match = string.match
local table_insert = table.insert

--- All metadata are collected in the following table.
local metadata = {}

--- The allowed formats for MetaInlines and MetaBlocks.
local ALLOWED_FORMATS = {
  plain = true,
  markdown = true,
  html = true,
  native = true,
}

---@type string The format to be used for MetaInlines and MetaBlocks.
local format = "plain"

---@type boolean Whether to detect numbers in MetaString and MetaInlines values.
local detect_numbers = false

---Set options' variables.
---@param vars table<string,Doc>
local function set_variables(vars)
  local f = tostring(vars.format or "plain")
  if ALLOWED_FORMATS[f] == true then
    format = f
  end
  info("MetaInlines and MetaBlocks format: " .. format)
  if not vars.numbers then
    detect_numbers = false
  else
    local n = tostring(vars.numbers)
    if n ~= "false" and n ~= "0" then
      detect_numbers = true
    end
  end
  if detect_numbers then
    info("Automatically detect numbers")
  end
end

---Checks if string is a stringified number.
---@param s string
local function is_number(s)
  return string_match(s, "^[%d]+$") or string_match(s, "^[%d]+[.][%d]+$")
end

---Convert a MetaValue into a JSON-equivalent object.
---@param value MetaValue
---@return string|boolean|number|table|nil
local function metaValue(value)
  local mtype = pandocType(value)
  if mtype == 'string' then
    if detect_numbers and is_number(value --[[@as string]]) then
      return tonumber(value)
    end
    return value
  elseif mtype == 'boolean' then
    return value
  elseif mtype == 'Inlines' then
    local s = pandoc.write(Pandoc({ Plain(value) }), format)
    -- remove eventual trailing newline
    s =  string_gsub(s, "[\r\n]+$", "")
    if detect_numbers and is_number(s) then
      return tonumber(s)
    end
    return s
  elseif mtype == 'Blocks' then
    return pandoc.write(Pandoc(value), format)
  elseif mtype == 'List' then
    local list = {}
    for i = 1, #value do
      table_insert(list, metaValue(value[i]))
    end
    return list
  elseif mtype == 'table' then
    local map = {}
    for k, v in pairs(value) do
      map[k] = metaValue(v)
    end
    return map
  else
    pandoc.log.warn(tostring(value) .. " is not a known MetaValue")
  end
  return nil
end

---@param meta Meta
local function extract_meta(meta)
  for k, v in pairs(meta) do
    metadata[k] = metaValue(v)
  end
end

function Writer(doc, opts)
  set_variables(opts.variables)
  doc:walk({ Meta = extract_meta })
  return pandoc.json.encode(metadata)
end
