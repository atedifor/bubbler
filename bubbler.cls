%% bubbler.cls
%% A LuaLaTeX-friendly alternative to Fountain, the screenwriting language.
%% Copyright (C) 2025  Eduard "Eddie" Forejt // atEdiFor
%
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3
% of this license or (at your option) any later version.
% The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3 or later is part of all distributions of LaTeX
% version 2005/12/01 or later.
%
% This work has the LPPL maintenance status `maintained'.
%
% The Current Maintainer of this work is identical with the copyright holder.
%
% This work consists of the files bubbler.cls and bubbler.lua.


%%%%%%%%%%%%%%%%%%%%%%%%
%% DOCUMENTCLASS INIT.
%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bubbler}

\newcommand{\bubblerversion}{1.0 May 2025}
\newcommand{\bubblerfileauthor}{Eduard "Eddie" Forejt // [at]EdiFor}

\newlinechar=`\^^J
\message{This is Bubbler (cls) by \bubblerfileauthor, Version \bubblerversion^^J}

\LoadClass[oneside]{book}


%%%%%%%%%%%
%% INDENT
%%%%%%%%%%%

\RequirePackage[a4paper, top=1in, right=1in, bottom=1.5in, left=1.5in]{geometry}

\RequirePackage[indent=0pt,skip=12pt]{parskip}

\RequirePackage{microtype}

\RequirePackage{multicol}


%%%%%%%%%%%%%
%% LANGUAGE
%%%%%%%%%%%%%

\RequirePackage{polyglossia}
\setdefaultlanguage{english}
\disablehyphenation


%%%%%%%%%%%%%%%%
%% PAGE LAYOUT
%%%%%%%%%%%%%%%%

\RequirePackage{xcolor}
\RequirePackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\rhead{\freg\thepage.\hspace{-1.5em}}
\lhead{\color{gray}{\hspace{-1.5em}\freg\bubblerheader}}
\rfoot{\color{gray}{\freg\bubblerfooter\hspace{-1.5em}}}


%%%%%%%%%%
%% FONTS
%%%%%%%%%%

\RequirePackage{ccicons}

\font\freg={[Courier Prime.ttf]} at12pt
\font\fbol={[Courier Prime Bold.ttf]} at12pt
\font\fita={[Courier Prime Italic.ttf]} at12pt
\font\fbolita={[Courier Prime Bold Italic.ttf]} at12pt

% \reg isn't necessary as it's the default font for this document class
\NewDocumentCommand{\bol}{ m }{\fbol#1\freg}
\NewDocumentCommand{\ita}{ m }{\fita#1\freg}
\NewDocumentCommand{\bolita}{ m }{\fbolita#1\freg}
\NewDocumentCommand{\uli}{ m }{\underline{#1}}


%%%%%%%%%%%%%%%%%%%
%% INIT. COUNTERS
%%%%%%%%%%%%%%%%%%%

%% Scene counter for scene numbering
\newcounter{scenes}

%% Helper counters for Lua _print_stats(...)
\newcounter{charlim}
\newcounter{scenlim}
\newcounter{scencat}

%% Switch for \maketitle, default to 1 (yes)
\newcounter{titlemake}
\setcounter{titlemake}{1}

%% Switch for numbering scenes, default to 1 (yes)
\newcounter{scenenum}
\setcounter{scenenum}{1}

%% Switch for bold scene titles, default to 1 (yes)
\newcounter{scenebol}
\setcounter{scenebol}{1}


%%%%%%%%%%%%%%%%%%%%
%% IMPORT LUA FILE
%%%%%%%%%%%%%%%%%%%%

%% Check that Lua is supported by the TeX engine
\ifdefined\directlua\else
   \message{ERROR: This document class is based on LuaLaTeX and requires the \\directlua macro to function properly.^^J}
   \endinput\fi

%% Check that "bubbler.lua" can be imported
\directlua{assert(require("bubbler"))}


%%%%%%%%%%%%%%%%%%
%% HELPER MACROS
%%%%%%%%%%%%%%%%%%

\RequirePackage{xifthen}

%% Skip \maketitle by setting titlemake to 0 (no)
\NewDocumentCommand{\skiptitle}{}{\setcounter{titlemake}{0}}

%% Disable scene numbering
\NewDocumentCommand{\noscenenumber}{}{\setcounter{scenenum}{0}}

%% Disable bold scene titles
\NewDocumentCommand{\noboldscene}{}{\setcounter{scenebol}{0}}

%% Conform to Oscar standards
\NewDocumentCommand{\oscarstyle}{}{%
\noscenenumber%
\noboldscene%
\directlua{require("bubbler").oscartype()}}

%% Clear page alias for the Lua _up_bubble(...) function, denotes top of content
\NewDocumentCommand{\contop}{}{\clearpage}

%% \par(skip) helper functions
\NewDocumentCommand{\unbubskip}{}{\setlength{\parskip}{0pt}}
\NewDocumentCommand{\rebubskip}{}{\setlength{\parskip}{12pt}}
\NewDocumentCommand{\br}{}{\par}

%% Join to previous paragraph, use \br for joining multiple lines
\NewDocumentCommand{\joinup}{ m }{%
\unbubskip%
#1%
\rebubskip}

%% Pad numbers to 5 digits by phantoming "0"
\NewDocumentCommand{\pad}{ m }{%
\ifnum #1 < 10000 \phantom{0}\fi\ifnum #1 < 1000 \phantom{0}\fi\ifnum #1 < 100 \phantom{0}\fi\ifnum #1 < 10 \phantom{0}\fi #1}

%% Center #1, align to \conv column
\NewDocumentCommand{\encen}{ m }{%
\hspace*{5.4em}%
\begin{minipage}{22em}%
\centering%
#1%
\end{minipage}}


%%%%%%%%%%%%%%%%%%%%%%
%% FORMATTING MACROS
%%%%%%%%%%%%%%%%%%%%%%

%% BONEYARD/COMMENTS (implented by comment package)
\RequirePackage{comment}

%% SCENE
\NewDocumentCommand{\scene}{ O{} O{} m }{%
\directlua{require("bubbler").addscene("#3", "#1", "#2")}%
\stepcounter{scenes}%
\ifthenelse{\equal{\arabic{scenebol}}{1}}{\fbol}{}%
\hspace{-5.8em}%
\ifthenelse{\equal{\arabic{scenenum}}{1}}{\pad{\arabic{scenes}}}{\phantom{\pad{\arabic{scenes}}}}%
\hspace{2em}
\ifthenelse{\isempty{#1}}{}{#1.~}%
#3%
\ifthenelse{\isempty{#2}}{}{~-~#2}%
\hfill%
\ifthenelse{\equal{\arabic{scenenum}}{1}}{\arabic{scenes}}{\phantom{\arabic{scenes}}}%
\hspace{-2em}%
\ifthenelse{\equal{\arabic{scenebol}}{1}}{\freg}{}}

%% CONVERSATION ACTION (helper to \conv and \diaconv)
\NewDocumentCommand{\inconv}{ m }{\hspace*{3em} (#1)\par}

%% CONVERSATION
\NewDocumentCommand{\conv}{ O{} O{} m m }{%
\directlua{require("bubbler").addchar("#3")}%
\begin{minipage}{\textwidth}%
\par\unbubskip%
\hspace{2in}%
#3%
\ifthenelse{\isempty{#1}}{}{~(#1)}\par%
\ifthenelse{\isempty{#2}}{\vspace{0.25em}}{\hspace{1.4in}(#2)\par}%
\hspace*{1in}%
\begin{minipage}{3.5in}%
\emergencystretch=2em%
\raggedright%
#4%
\end{minipage}%
\end{minipage}%
\rebubskip}

%% CONVERSATION (helper for \dia)
\NewDocumentCommand{\diaconv}{ O{} O{} m m }{%
\directlua{require("bubbler").addchar("#3")}%
\par\unbubskip%
\hspace{1in}%
#3%
\ifthenelse{\isempty{#1}}{}{~(#1)}\par%
\ifthenelse{\isempty{#2}}{\vspace{0.25em}}{\hspace{0.7in}(#2)\par}%
\hspace*{0.5in}%
\begin{minipage}{1.75in}%
\emergencystretch=1em%
\raggedright%
#4%
\end{minipage}%
\rebubskip}

%% DIALOGUE
\NewDocumentCommand{\dia}{ m m }{%
\begin{multicols}{2}
#1
#2
\end{multicols}}

%% CUT
\NewDocumentCommand{\cut}{ m }{\hfill #1}

%% LYRICS
\NewDocumentCommand{\lyric}{ m }{\ita{#1}}

%% SCENE MUSIC (to be used with \scene)
\NewDocumentCommand{\music}{ m }{\vspace{-12pt}\ita{~#1}}

%% SEGMENT
\NewDocumentCommand{\seg}{ m }{\encen{\bol{#1}}}

%% SEGMENT WITH \clearpage
\NewDocumentCommand{\cseg}{ m }{%
\clearpage

\encen{\bol{#1}}}


%%%%%%%%%%%%%%%
%% LUA MACROS
%%%%%%%%%%%%%%%

%% Prints out statistics about the given file
\NewDocumentCommand{\printstats}{ O{10} O{5} O{1} }{%
\ifthenelse{\equal{#3}{-1}}{}{\directlua{require("bubbler").printstats(#1, #2, #3)}}}

%% Merges another script into the current one, skipping until \begin{script} && \contop
\NewDocumentCommand{\upbubble}{ O{} m }{%
\ifthenelse{\isempty{#1}}{\directlua{require("bubbler").upbubble("#2")}}{\ifthenelse{\equal{#1}{.}}{%
\clearpage

\directlua{require("bubbler").upbubble("#2")}}{%
\cseg{#1}

\directlua{require("bubbler").upbubble("#2")}}}}

%% Import .fountain file as inline
\NewDocumentCommand{\rebubble}{ O{} m }{%
\ifthenelse{\isempty{#1}}{\directlua{require("bubbler").rebubble("#2")}}{\ifthenelse{\equal{#1}{.}}{%
\clearpage

\directlua{require("bubbler").rebubble("#2")}}{%
\cseg{#1}

\directlua{require("bubbler").rebubble("#2")}}}}

%% Clear current character context
\NewDocumentCommand{\clearmem}{}{\directlua{reguire("bubbler").memclear()}}

%% Make list of characters in current context
\NewDocumentCommand{\dumpmem}{ O{} }{%
\ifthenelse{\isempty{#1}}{\directlua{require("bubbler").memdump()}}{\ifthenelse{\equal{#1}{.}}{%
\clearpage

\directlua{require("bubbler").memdump()}}{%
\cseg{#1}

\directlua{require("bubbler").memdump()}}}}


%%%%%%%%%%%%%%%
%% TITLE PAGE
%%%%%%%%%%%%%%%

%% Default, change using \renewcommand{GIVEN_TYPE}{TEXT}
\newcommand{\bubblertitle}{}
\newcommand{\bubblercredit}{}
\newcommand{\bubblerauthor}{}
\newcommand{\bubblersource}{}
\newcommand{\bubblernotes}{}
\newcommand{\bubblerdraftdate}{}
\newcommand{\bubblerdate}{}
\newcommand{\bubblercontact}{}
\newcommand{\bubblercopyright}{}
\newcommand{\bubblerrevision}{}
\newcommand{\bubblerheader}{}
\newcommand{\bubblerfooter}{}

%% NOT to be changed manually, used by titlestacker
\newcommand{\bubblerbrq}{}
\newcommand{\bubblerbrt}{}
\newcommand{\bubblerbrd}{}
\newcommand{\bubblerbru}{}
\newcommand{\bubblerbld}{}
\newcommand{\bubblerblu}{}

%% Show up names of spaces for title page and header/footer
\NewDocumentCommand{\titlehelp}{}{%
\renewcommand{\bubblertitle}{bubblertitle}
\renewcommand{\bubblercredit}{bubblercredit}
\renewcommand{\bubblerauthor}{bubblerauthor}
\renewcommand{\bubblersource}{bubblersource}
\renewcommand{\bubblernotes}{bubblernotes}
\renewcommand{\bubblerdraftdate}{bubblerdraftdate}
\renewcommand{\bubblerdate}{bubblerdate}
\renewcommand{\bubblercontact}{bubblercontact}
\renewcommand{\bubblercopyright}{bubblercopyright}
\renewcommand{\bubblerrevision}{bubblerrevision}
\renewcommand{\bubblerheader}{bubblerheader}
\renewcommand{\bubblerfooter}{bubblerfooter}}

%% Title bottom layout
\NewDocumentCommand{\titlestacker}{}{%
\ifthenelse{\equal{\bubblercopyright}{}}{}{\renewcommand{\bubblerblu}{\bubblercopyright}}%
\ifthenelse{\equal{\bubblernotes}{}}{}{\ifthenelse{\equal{\bubblerblu}{}}{\renewcommand{\bubblerblu}{\bubblernotes}}{\renewcommand{\bubblerbld}{\bubblernotes}}}%
\ifthenelse{\equal{\bubblercontact}{}}{}{\renewcommand{\bubblerbru}{\bubblercontact}}%
\ifthenelse{\equal{\bubblerdraftdate}{}}{}{\ifthenelse{\equal{\bubblerbru}{}}{\renewcommand{\bubblerbru}{\bubblerdraftdate}}{\renewcommand{\bubblerbrd}{\bubblerdraftdate}}}%
\ifthenelse{\equal{\bubblerdate}{}}{}{\ifthenelse{\equal{\bubblerbru}{}}{\renewcommand{\bubblerbru}{\bubblerdate}}{\ifthenelse{\equal{\bubblerbrd}{}}{\renewcommand{\bubblerbrd}{\bubblerdate}}{\renewcommand{\bubblerbrt}{\bubblerdate}}}}%
\ifthenelse{\equal{\bubblerrevision}{}}{}{\ifthenelse{\equal{\bubblerbru}{}}{\renewcommand{\bubblerbru}{\bubblerrevision}}{\ifthenelse{\equal{\bubblerbrd}{}}{\renewcommand{\bubblerbrd}{\bubblerrevision}}{\ifthenelse{\equal{\bubblerbrt}{}}{\renewcommand{\bubblerbrt}{\bubblerrevision}}{\renewcommand{\bubblerbrq}{\bubblerrevision}}}}}}

%% Renew layout
\renewcommand{\maketitle}{
\begin{titlepage}
\vspace*{\fill}
\begin{center}
\bubblertitle

\bubblercredit

\bubblerauthor

\bubblersource
\end{center}
\vfill
\titlestacker
\raggedright
\ifthenelse{\equal{\bubblerbrq}{}}{}{\hspace*{\fill}\begin{minipage}{\textwidth/2}\raggedleft\bubblerbrq\end{minipage}\par}
\ifthenelse{\equal{\bubblerbrt}{}}{}{\hspace*{\fill}\begin{minipage}{\textwidth/2}\raggedleft\bubblerbrt\end{minipage}\par}
\ifthenelse{\equal{\bubblerbrd}{}}{\ifthenelse{\equal{\bubblerbld}{}}{}{\bubblerbld\par}}{\bubblerbld\hspace*{\fill}\begin{minipage}{\textwidth/2}\raggedleft\bubblerbrd\end{minipage}\par}
\ifthenelse{\equal{\bubblerbru}{}}{\ifthenelse{\equal{\bubblerblu}{}}{}{\bubblerblu\par}}{\bubblerblu\hspace*{\fill}\begin{minipage}{\textwidth/2}\raggedleft\bubblerbru\end{minipage}\par}
\end{titlepage}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN SCRIPT ENVIRONMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NewDocumentEnvironment{script}{ O{0} O{0} O{-1} }{%
\setcounter{charlim}{#1}\setcounter{scenlim}{#2}\setcounter{scencat}{#3}
\freg\ifthenelse{\equal{\arabic{titlemake}}{1}}{\maketitle}{}
\emergencystretch=4em\begin{raggedright}}{%
\end{raggedright}
\printstats[\arabic{charlim}][\arabic{scenlim}][\arabic{scencat}]}
