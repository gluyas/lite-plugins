local core = require "core"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"

config.autoinsert_map = {
  ["{%s*\n"] = "}",
  ["%(%s*\n"] = ")",
  ["%f[[]%[%s*\n"] = "]",
  ["%[%[%s*\n"] = "]]",
  ["=%s*\n"] = false,
  [":%s*\n"] = false,
  ["^#if%s*\n"] = "#endif",
  ["^#else%s*\n"] = "#endif",
  ["%f[%w]do%s*\n"] = "end",
  ["%f[%w]then%s*\n"] = "end",
  ["%f[%w]else%s*\n"] = "end",
  ["%f[%w]repeat%s*\n"] = "until",
  ["%f[%w]function.*%)%s*\n"] = "end",
}


local function indent_size(doc, line)
  local text = doc.lines[line] or ""
  local s, e = text:find("^[\t ]*")
  return e - s
end

command.add("core.docview", {
  ["autoinsert:newline"] = function()
    command.perform("doc:newline")

    local doc = core.active_view.doc
    local line, col = doc:get_selection()
    local text = doc.lines[line - 1]

    for ptn, close in pairs(config.autoinsert_map) do
      if text:find(ptn) then
        if  close
        and col == #doc.lines[line]
        and indent_size(doc, line + 1) <= indent_size(doc, line - 1)
        then
          command.perform("doc:newline")
          core.active_view:on_text_input(close)
          command.perform("doc:move-to-previous-line")
        end
        command.perform("doc:indent")
      end
    end
  end
})

keymap.add {
  ["return"] = { "command:submit", "autoinsert:newline" }
}
