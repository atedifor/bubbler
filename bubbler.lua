#!/usr/bin/env lua
---- bubbler.lua
---- A LuaLaTeX-friendly alternative to Fountain, the screenwriting language.
---- Copyright (C) 2025  Eduard "Eddie" Forejt // atEdiFor
--
-- This work may be distributed and/or modified under the
-- conditions of the LaTeX Project Public License, either version 1.3
-- of this license or (at your option) any later version.
-- The latest version of this license is in
--   http://www.latex-project.org/lppl.txt
-- and version 1.3 or later is part of all distributions of LaTeX
-- version 2005/12/01 or later.
--
-- This work has the LPPL maintenance status `maintained'.
--
-- The Current Maintainer of this work is identical with the copyright holder.
--
-- This work consists of the files bubbler.cls and bubbler.lua.


-- VARIABLE INITIALIZATION
_bubbler_version = '1.1 May 2025'
_bubbler_file_author = 'Eduard "Eddie" Forejt // [at]EdiFor'

_chars = 0
_char = {}
_char_mem = {}

_scenes = 0
_scene = {}
_scene_inex = {INT = 0, EXT = 0, NOT = 0}
_scene_dani = {NOT = 0}
_scene_dani_warn = false


-- FORMATTING FUNCTIONS
local function _header(cat, tot, txt)
    print("\n" .. string.format("===== %s (%d %s) =====", cat, tot, txt))
end


local function _seperator()
    print("\n\t======\n")
end


local function _list_vals(dic, sum, lim)
    local _dic_srtd = {}

    for k in pairs(dic) do
        table.insert(_dic_srtd, k)
    end

    table.sort(_dic_srtd, function(x, y) return dic[x] > dic[y] end)

    for i, k in ipairs(_dic_srtd) do
        if lim ~= -1 and i > lim then
            break
        end

        print(string.format("%5d\t%5.2f%%\t%s", dic[k], 100 * dic[k] / sum, k))
    end
end


-- MEMORY MANIPULATION FUNCTIONS
local function _mem_append(nam)
    for i = 1, #_char_mem do
        if _char_mem[i] == nam then
            return
        end
    end
    _char_mem[#_char_mem + 1] = nam
end


local function _mem_clear()
    _char_mem = {}
end


local function _mem_dump()
    local r = "\\begin{itemize}"
    for i = 1, #_char_mem do
        r = r.."\\item ".._char_mem[i]..""
    end
    r = r.."\\end{itemize}\\par\n"
    tex.print(r)
    _mem_clear()
end


-- OSCAR WARN FUNCTION
local function _oscar_type()
    _scene_dani_warn = true
end


-- COUNTER FUNCTIONS
local function _add_char(nam)
    assert(nam ~= nil and nam ~= "", "\nERROR: Character name must be given, got '"..nam.."'.")

    _chars = _chars + 1

    _mem_append(nam)

    if _char[nam] == nil then
        _char[nam] = 1
    else
        _char[nam] = _char[nam] + 1
    end
end


local function _add_scene(nam, ine, dan)
    assert(nam ~= nil and nam ~= "", "\nERROR: Scene name must be given, got '"..nam.."'.")
    assert(ine == "INT" or ine == "EXT" or ine == "" or ine == nil, "\nERROR: Scene type must be 'INT' or 'EXT', got '"..ine.."'.")

    _scenes = _scenes + 1

    if _scene[nam] == nil then
        _scene[nam] = 1
    else
        _scene[nam] = _scene[nam] + 1
    end

    if ine ~= nil and ine ~= "" then
        _scene_inex[ine] = _scene_inex[ine] + 1
    else
        _scene_inex["NOT"] = _scene_inex["NOT"] + 1
    end

    if dan ~= nil and dan ~= "" then
        if dan ~= "DAY" and dan ~= "NIGHT" and _scene_dani_warn then
            print("\nWARN: Scene daytimes other than 'DAY' or 'NIGHT' are generally frowned upon by the Oscar comitee, you have been warned.")
            _scene_dani_warn = false
        end

        if _scene_dani[dan] == nil then
            _scene_dani[dan] = 1
        else
            _scene_dani[dan] = _scene_dani[dan] + 1
        end
    else
        _scene_dani["NOT"] = _scene_dani["NOT"] + 1
    end
end


-- STATS PRINTING FUNCTION
local function _print_stats(cli, sli, sca)
    if _chars == 1 then
        _header("CHARACTER", _chars, "speech")
    else
        _header("CHARACTERS", _chars, "speeches")
    end
    _list_vals(_char, _chars, cli)

    if _scenes == 1 then
        _header("SCENES", _scenes, "total")
    else
        _header("SCENE", _scenes, "total")
    end
    _list_vals(_scene, _scenes, sli)

    if sca == 1 then
        _seperator()
        _list_vals(_scene_inex, _scenes, -1)

        _seperator()
        _list_vals(_scene_dani, _scenes, -1)
    else
        print("\n\nDEBUG: Skipping scene categories...")
    end
end


-- SCRIPT MERGING FUNCTION
local function _up_bubble(scr)
    if not string.find(scr, ".tex") then
        scr = scr..".tex"
    end

    local f = io.open(scr, "r")
    assert(f, "\nERROR: Failed to open file ("..scr..") for upbubble.")
    local ls = f:lines()

    local p = false
    local w = false
    for l in ls do
        if p then
            if string.find(l, "\\upbubble") then
                if not w then
                    print("\nWARN: Upbubble recursion not allowed.")
                    w = true
                end
            else
                tex.print(l)
            end
        elseif string.find(l, "\\contop") then
            p = true
        elseif string.find(l, "\\end{script}") then
            if not p then
                print("\nWARN: Top of content not found, nothing to upbubble.")
            end
            p = false
            break
        end
    end

    f:close()
end


-- STRING MODIFICATION FUNCTIONS
local function _rem_ws(str)
    while str:sub(1, 1) == " " do
        str = str:sub(2)
    end
    return str
end


local function _rem_tws(str)
    while str:sub(-1) == " " do
        str = str:sub(1, #str-1)
    end
    return str
end

local function _rem_wws(str)
    return _rem_tws(_rem_ws(str))
end


local function _str_ex(str)
    return str ~= "" and str ~= nil
end

local function _starts_with(str, chk)
    return str:sub(1, #chk) == chk
end


local function _ends_with(str, chk)
    return str:sub(-#chk) == chk
end


-- FOUNTAIN-TO-BUBBLER FUNCTIONS
local function _scene_morph(l)
    local m = {}
    local i = 1

    for v in string.gmatch(l, "[^-]+") do
        if i == 1 then
            m[1] = _rem_tws(v)
        end

        if i == 2 then
            m[2] = _rem_ws(v)
        end

        i = i + 1
    end

    if m[1] == nil then
        m[1] = ""
    end

    if m[2] == nil then
        m[2] = ""
    end

    return m
end


local function _re_bubble(src, file)
    if not string.find(src, ".fountain") then
        src = src..".fountain"
    end

    local f = io.open(src, "r")
    assert(f, "\nERROR: Failed to open source file ("..src..") for rebubble.")
    print("\nINFO: Migrating file ("..src..") to Bubbler, please stand by...")
    local ls = f:lines()

    -- CONTEXT SWITCHES
    local CTX_NONE = 0
    local CTX_CONT = 1
    local CTX_CONV = 2
    local CTX_SPAR = 3
    local CTX_MPAR = 4
    local CTX_DCON = 5
    local CTX_DIAC = 6
    local CTX_COMM = 7

    local s = CTX_NONE
    local c = 0
    local li = 1
    local d = {type = "", method = "", name = "", text = ""}
	local p = true
    local r = ""
    if file then r = "\\documentclass{bubbler}\n\n" end
    for l in ls do
		p = true
        li = 1

        l, li = string.gsub(l, "%[%[", "\\begin{comment}\n")
        if li ~= 0 then
            s = CTX_COMM
        end

        l, li = string.gsub(l, "/%*", "\\begin{comment}\n")
        if li ~= 0 then
            s = CTX_COMM
        end

        l, li = string.gsub(l, "%]%]", "\n\\end{comment}")
        if li ~= 0 then
            s = CTX_COMM
            p = false
        end

        l, li = string.gsub(l, "%*/", "\n\\end{comment}")
        if li ~= 0 then
            s = CTX_COMM
            p = false
        end

        if s == CTX_COMM then
			r = r..l.."\n"
            if p == true then
                p = false
            else
                s = CTX_NONE
            end
        end

        if p then
            l = string.gsub(l, "\r", "")
            l = string.gsub(l, "\t", "    ")
            l = string.gsub(l, "\\", "\\textbackslash ")
            while li > 0 do l, li = string.gsub(l, "##", "#") end
            l = string.gsub(l, "#", "\\#")
            l = string.gsub(l, "%$", "\\$")
            l = string.gsub(l, "%%", "\\%%")
            l = string.gsub(l, "===", "\\clearpage")
            l = string.gsub(l, "=", "%%")
            l = string.gsub(l, "&", "\\&")
            l = string.gsub(l, "{", "\\{")
            l = string.gsub(l, "}", "\\}")
            l = string.gsub(l, "~", "\\~")
            l = string.gsub(l, "%^", "\\^")
            l = string.gsub(l, "_([^_]+)_", "\\uli{%1}")
            l = string.gsub(l, "_", "\\_")
            l = string.gsub(l, "%*%*%*([^%*]+)%*%*%*", "\\bolita{%1}")
            l = string.gsub(l, "%*%*([^%*]+)%*%*", "\\bol{%1}")
            l = string.gsub(l, "%*([^%*]+)%*", "\\ita{%1}")
        end

        if p and _starts_with(l, "\\~") then
            l = _rem_ws(l:sub(3))
            l = "\\lyric{"..l.."}"
        end

        if p and c == 0 then
            l = string.gsub(l, "%(C%)", "\\ccCopy~")
            l = string.gsub(l, "CC BY%-NC%-ND ", "\\ccbyncnd~")
            l = string.gsub(l, "CC BY%-NC%-SA ", "\\ccbyncsa~")
            l = string.gsub(l, "CC BY%-NC ", "\\ccbync~")
            l = string.gsub(l, "CC BY%-ND ", "\\ccbynd~")
            l = string.gsub(l, "CC BY%-SA ", "\\ccbysa~")
            l = string.gsub(l, "CC BY ", "\\ccby~")
            l = string.gsub(l, "CC0 ", "\\cczero~")
        end

        if p and s == CTX_CONT then
            if l:sub(1, 1) == " " then
                l = _rem_ws(l)
                if file then r = r..l.."\\br\n" end
                p = false
            else
                if file then r = r:sub(1, #r-4).."\n\\rebubskip}\n" end
                s = CTX_NONE
            end
        end

        if p and _starts_with(l, "Title:") then
            if l:sub(8) == "" then
                if file then r = r.."\\renewcommand{\\bubblertitle}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblertitle}{"..l:sub(8).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Credit:") then
            if l:sub(9) == "" then
                if file then r = r.."\\renewcommand{\\bubblercredit}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblercredit}{"..l:sub(9).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Author:") then
            if l:sub(9) == "" then
                if file then r = r.."\\renewcommand{\\bubblerauthor}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblerauthor}{"..l:sub(9).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Source:") then
            if l:sub(9) == "" then
                if file then r = r.."\\renewcommand{\\bubblersource}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblersource}{"..l:sub(9).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Notes:") then
            if l:sub(8) == "" then
                if file then r = r.."\\renewcommand{\\bubblernotes}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblernotes}{"..l:sub(8).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Draft Date:") or _starts_with(l, "Draft date:") then
            if l:sub(13) == "" then
                if file then r = r.."\\renewcommand{\\bubblerdraftdate}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblerdraftdate}{"..l:sub(13).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Date:") then
            if l:sub(7) == "" then
                if file then r = r.."\\renewcommand{\\bubblerdate}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblerdate}{"..l:sub(7).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Contact:") then
            if l:sub(10) == "" then
                if file then r = r.."\\renewcommand{\\bubblercontact}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblercontact}{"..l:sub(10).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Copyright:") then
            if l:sub(12) == "" then
                if file then r = r.."\\renewcommand{\\bubblercopyright}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblercopyright}{"..l:sub(12).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Revision:") then
            if l:sub(11) == "" then
                if file then r = r.."\\renewcommand{\\bubblerrevision}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblerrevision}{"..l:sub(11).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Header:") then
            if l:sub(9) == "" then
                if file then r = r.."\\renewcommand{\\bubblerheader}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblerheader}{"..l:sub(9).."}\n" end
            end
            p = false
        end

        if p and _starts_with(l, "Footer:") then
            if l:sub(9) == "" then
                if file then r = r.."\\renewcommand{\\bubblerfooter}{%\n\\unbubskip\n" end
                s = CTX_CONT
            else
                if file then r = r.."\\renewcommand{\\bubblerfooter}{"..l:sub(9).."}\n" end
            end
            p = false
        end

        if s == CTX_DCON then
            if _ends_with(l, "\\^") then
                r = r.."\\dia{%\n\\diaconv["..d["type"].."]["..d["method"].."]{"..d["name"].."}{%\n"..d["text"].."}}{%\n"
                d = {type = "", method = "", name = "", text = ""}

                local i = 1
                for v in string.gmatch(l, "[^%(]+") do
                    if i == 1 then
                        d["name"] = _rem_wws(v:sub(1, #v-2))
                    end

                    if i == 2 then
                        d["type"] = string.gsub(v, ")", "")
                    end

                    i = i + 1
                end

                s = CTX_DIAC
                d["text"] = ""
                p = false
            else
                r = r.."\\conv["..d["type"].."]["..d["method"].."]{"..d["name"].."}{%\n"..d["text"].."}\n\n"
                d = {type = "", method = "", name = "", text = ""}
                s = CTX_NONE
            end
        end

        if p and l == "  " then
            p = false
        end

        if p and l == "" then
            if c == 0 then
                c = 1
                if file then
                    r = r.."\n\\begin{document}\n\\begin{script}\n\n\\contop\n\n"
                end
            end

            if s == CTX_CONV then
                s = CTX_DCON
            end

            if s == CTX_DIAC then
                r = r.."\\diaconv["..d["type"].."]["..d["method"].."]{"..d["name"].."}{%\n"..d["text"].."}}\n\n"
                d = {type = "", method = "", name = "", text = ""}
                s = CTX_NONE
            end

            if s == CTX_SPAR then
                s = CTX_NONE
            end

            if s == CTX_MPAR then
                r = r:sub(1, #r-4).."}\n\n"
                s = CTX_NONE
            end

            p = false
        end

        if p then
            if s == CTX_CONV or s == CTX_DIAC then
                l = _rem_ws(l)

                if l:sub(1, 1) == "(" then
                    if d["text"] == "" then
                        d["method"] = _rem_tws(l):sub(2, #l-1)
                    else
                        d["text"] = d["text"].."\\br\n\\inconv{"..l:sub(2, #l-1).."}"
                    end
                elseif d["text"] == "" then
                    d["text"] = l
                else
                    d["text"] = d["text"].."\\br\n"..l
                end

                p = false
            end
        end

        if p and _starts_with(l, "\\#") then
            l = _rem_ws(l:sub(3))
            r = r.."\\seg{"..l.."}\n\n"
            p = false
        end

        if p and _starts_with(l, "!") then
            l = _rem_ws(l:sub(2))

            if s == CTX_MPAR then
                r = r..l.."\\br\n"
            elseif s == CTX_SPAR then
                r = r.."\\joinup{%\n"..l.."\\br\n"
                s = CTX_MPAR
            else
			    r = r..l.."\n\n"
                s = CTX_SPAR
            end

            p = false
        end

        if p and _starts_with(l, "@") then
            l = _rem_ws(l:sub(2))

            local i = 1

            for v in string.gmatch(l, "[^%(]+") do
                if i == 1 then
                    d["name"] = _rem_ws(v)
                end

                if i == 2 then
                    d["type"] = string.gsub(v, ")", "")
                end

                i = i + 1
            end

            s = CTX_CONV
            d["text"] = ""
            p = false
        end

        if p and _starts_with(l, "INT.") then
            l = l:sub(6)
            local m = _scene_morph(l)
            r = r.."\\scene[INT]["..m[2].."]{"..m[1].."}\n\n"
            p = false
        end

        if p and _starts_with(l, "INT") then
            l = l:sub(5)
            local m = _scene_morph(l)
            r = r.."\\scene[INT]["..m[2].."]{"..m[1].."}\n\n"
            p = false
        end

        if p and _starts_with(l, "EXT.") then
            l = l:sub(6)
            local m = _scene_morph(l)
            r = r.."\\scene[EXT]["..m[2].."]{"..m[1].."}\n\n"
            p = false
        end

        if p and _starts_with(l, "EXT") then
            l = l:sub(5)
            local m = _scene_morph(l)
            r = r.."\\scene[EXT]["..m[2].."]{"..m[1].."}\n\n"
            p = false
        end

        if p and _starts_with(l, ".") then
            l = l:sub(2)
            l = _rem_ws(l)
            local m = _scene_morph(l)
            r = r.."\\scene[]["..m[2].."]{"..m[1].."}\n\n"
            p = false
        end

        if p and _ends_with(l, ":") then
            l = _rem_ws(l)
            r = r.."\\cut{"..l.."}\n\n"
            p = false
        end

        if p and _starts_with(l, ">") and _ends_with(l, "<") then
            l = _rem_ws(l:sub(2))
            l = _rem_tws(l:sub(1, #l-1))
            r = r.."\\encen{"..l.."}\n\n"
            p = false
        end

        if p and _starts_with(l, ">") then
            l = _rem_ws(l:sub(2))
            r = r.."\\cut{"..l.."}\n\n"
            p = false
        end

        if p then
            local i = 1
            for v in string.gmatch(l, "[^%(]+") do
                if i == 1 then
                    for w in string.gmatch(l, "[A-Z0-9 ]+") do
                        if v == w then
                            d["name"] = _rem_ws(v)
                        end
                    end
                end

                if i == 2 then
                    d["type"] = _rem_tws(v):sub(1, #v-1)
                end

                i = i + 1
            end

            if d["name"] ~= "" then
                s = CTX_CONV
                d["text"] = ""
                p = false
            else
                d = {type = "", method = "", name = "", text = ""}
            end
        end

		if p then
            if s == CTX_MPAR then
                r = r..l.."\\br\n"
            elseif s == CTX_SPAR then
                r = r.."\\joinup{%\n"..l.."\\br\n"
                s = CTX_MPAR
            else
			    r = r..l.."\n\n"
                s = CTX_SPAR
            end
		end
    end

    if file then
        r = r.."\\end{script}\n\\end{document}\n"
    end

    print("\nINFO: Finished migration of source file ("..src..") to Bubbler.")

    f:close()
    return r
end


local function _re_bubble_inline(src)
    local r = string.gsub(_re_bubble(src, false), "\n\n", "\\par\n")
    print(r)
    for l in r:gmatch("([^\n]*)\n?") do
        tex.print(l)
    end
end


local function _re_bubble_file(src, dst)
    if not string.find(src, ".tex") then
        dst = dst..".tex"
    end

    local f = io.open(dst, "w")
    assert(f, "\nERROR: Failed to open destination file ("..dst..") for rebubble.")
    f:write(_re_bubble(src, true))
    print("\nINFO: Saved output of rebubble to destination file ("..dst..").")

    f:close()
end


-- BATCH/INTERACTIVE MODE SWITCH
if tex ~= nil then
    print("\nThis is Bubbler (lua) by ".._bubbler_file_author..", Version ".._bubbler_version)
else
    if #arg == 0 then
        print("\nUsage: "..arg[0].." source[.fountain] [destination[.tex]]")
    elseif #arg == 1 then
        if arg[1] == "-h" or arg[1] == "--help" or string.find(arg[1], ".tex") then
            print("\nUsage: "..arg[0].." source[.fountain] [destination[.tex]]")
        elseif not string.find(arg[1], ".fountain") then
            _re_bubble_file(arg[1], arg[1])
        elseif string.find(arg[1], ".fountain") then
            print("\nWARN: Assuming error in arguments. If you want the input and output file for rebubble to use the same name, remove '.fountain' from '"..arg[1].."'.")
        end
    elseif #arg == 2 then
        if string.find(arg[1], ".tex") or string.find(arg[2], ".fountain") then
            print("\nUsage: "..arg[0].." source[.fountain] [destination[.tex]]")
        else
            _re_bubble_file(arg[1], arg[2])
        end
    end
end


-- EXPORT FUNCTIONS
return { addscene = _add_scene, addchar = _add_char, printstats = _print_stats, upbubble = _up_bubble, rebubble = _re_bubble_inline, memclear = _mem_clear, memdump = _mem_dump, oscartype = _oscar_type }

